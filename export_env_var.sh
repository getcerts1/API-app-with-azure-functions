#!/bin/bash
#!/bin/bash

# Load environment variables from modify_env.env
export TF_VAR_client_id=$(grep 'ARM_CLIENT_ID' modify_env.env | cut -d '=' -f2)
export TF_VAR_client_secret=$(grep 'ARM_CLIENT_SECRET' modify_env.env | cut -d '=' -f2)
export TF_VAR_subscription_id=$(grep 'ARM_SUBSCRIPTION_ID' modify_env.env | cut -d '=' -f2)
export TF_VAR_tenant_id=$(grep 'ARM_TENANT_ID' modify_env.env | cut -d '=' -f2)

# Persist in .bashrc for future sessions
echo "export ARM_CLIENT_ID=${TF_VAR_client_id}" >> ~/.bashrc
echo "export ARM_CLIENT_SECRET=${TF_VAR_client_secret}" >> ~/.bashrc
echo "export ARM_SUBSCRIPTION_ID=${TF_VAR_subscription_id}" >> ~/.bashrc
echo "export ARM_TENANT_ID=${TF_VAR_tenant_id}" >> ~/.bashrc

# Apply changes immediately
source ~/.bashrc

