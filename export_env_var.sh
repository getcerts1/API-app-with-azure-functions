#!/bin/bash

# Define the function to unset environment variables when the shell exits
function unset_env_vars {
    unset $(grep -v '^#' modify_env.env | cut -d= -f1)
    echo "Environment variables have been cleared."
}

# Trap the exit signal and call the unset function
trap unset_env_vars EXIT

# Read the .env file and export variables for the current session
if [ -f modify_env.env ]; then
    while IFS='=' read -r key value; do
        # Skip lines that are empty or comments
        if [[ -z "$key" || "$key" =~ ^# ]]; then
            continue
        fi
        # Export each variable for the current session
        export "$key"="$value"
    done < modify_env.env
fi

# Notify that the variables have been set
echo "Environment variables from .env are set for this session."
