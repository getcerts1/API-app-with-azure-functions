import json
import os
import subprocess

ACCOUNT_INFO_OUTPUT_FILE = "account_output.json"
SP_OUTPUT_FILE = "sp_output.json"
SUB_ID = ""

#retrieve subscription id value from command_output if user exists
username = input("Enter username: \n").strip()
command_output = subprocess.run(["az", "account", "list", "--output", "json"],
                                capture_output=True, text=True)

account_list = json.loads(command_output.stdout)
found = False

for account in account_list:
    if account["user"]["name"] == username:
        found = True
        SUB_ID += account.get("id", "")



    # check if sp exists, if not use file redirection to write creation output to SP_OUTPUT_FILE
    try:
        az_ad_sp_check = subprocess.run(
            ["az", "ad", "sp", "show", "--id", SUB_ID],
            capture_output=True, text=True, check=True
        )
        sp_exists = True
        os.system(f"az ad sp show --id {SUB_ID}> {SP_OUTPUT_FILE}")

    except subprocess.CalledProcessError:
        sp_exists = False
        print(f"service principle {SUB_ID} does not exist")
        app_command = (f"az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/{SUB_ID}\""
                       f" --output json > {SP_OUTPUT_FILE}")
        os.system(app_command)



    # retrieve service principle information and save to var
    with open(SP_OUTPUT_FILE, "r") as file:
        output = json.load(file)
        app_id = output.get("appId", "")
        password = output.get("password", "")
        tenant = output.get("tenant", "")

    # write to .env file
    with open("modify_env.env.example", "w") as env_file:
        env_file.write(f"ARM_CLIENT_ID={app_id}\n")
        env_file.write(f"ARM_CLIENT_SECRET={password}\n")
        env_file.write(f"ARM_SUBSCRIPTION_ID={SUB_ID}\n")
        env_file.write(f"ARM_TENANT_ID={tenant}\n")

    os.system("./export_env_var.sh")
    os.system("source export_env_var.sh")


if not found:
    print(f"username '{username}' is not found")







