#!/bin/bash
set -e

# Purpose:
# ----------
# This script manages infrastructure by creating changesets or deploying resources.

# Arguments:
# ----------
#   --environment-name      | Target environment where AWS resources will be managed.
#                           | Possible values: npd, nft, prd
#   --action                | Action to perform: create-changeset or deploy
#   --debug                 | Optional. true if you want to enable debug logging, false by default

echo "=============================="
echo "[START] Infrastructure management started at $(date +"%d-%m-%Y %H:%M")"
echo "=============================="

APPLICATION_NAME=ccsa-ga-test-aws-infra
ENVIRONMENT_NAME=
ACTION=
DEBUG=false

while [ -n "$1" ]
do
    case "$1" in
        --environment-name)
            ENVIRONMENT_NAME=$2
            shift ;;
        --action)
            ACTION=$2
            shift ;;
        --debug)
            DEBUG=$2
            shift ;;
        *)
            echo "$1 is not a valid option"
            exit 1 ;;
    esac
    shift
done

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Error: environment-name is required"
    exit 1
fi

if [ -z "$ACTION" ]; then
    echo "Error: action is required (create-changeset or deploy)"
    exit 1
fi

# Function to manage resources (create/update change set or deploy)
manage_resources () {
    local STACK_NAME=$1
    local STACK_TEMPLATE=$2
    local STACK_PARAMETERS=$3

    if [ "$ACTION" == "create-changeset" ]; then
        echo "=============================="
        echo "Creating changeset for stack: $STACK_NAME"
        echo "=============================="

        aws cloudformation deploy \
            --no-execute-changeset \
            --no-fail-on-empty-changeset \
            --stack-name "$STACK_NAME" \
            --template-file "$STACK_TEMPLATE" \
            --parameter-overrides $(cat "$STACK_PARAMETERS")
    elif [ "$ACTION" == "deploy" ]; then
        echo "=============================="
        echo "Deploying stack: $STACK_NAME"
        echo "=============================="

        aws cloudformation deploy \
            --no-fail-on-empty-changeset \
            --stack-name "$STACK_NAME" \
            --template-file "$STACK_TEMPLATE" \
            --parameter-overrides $(cat "$STACK_PARAMETERS")
    else
        echo "Unsupported action: $ACTION"
        exit 1
    fi
}

# Function to handle resources dynamically
handle_resources() {
    local parameters_dir="Infrastructure/Parameters/${ENVIRONMENT_NAME}"

    echo "Checking parameters directory: $parameters_dir"

    if [ ! -d "$parameters_dir" ]; then
        echo "Error: Parameters directory for environment $ENVIRONMENT_NAME does not exist."
        exit 1
    fi

    echo "Looking for .properties files in $parameters_dir"
    ls "$parameters_dir"/*.properties 2>/dev/null || echo "No .properties files found in $parameters_dir"

    # Loop through all parameter files in the parameters directory
    for param_file in "$parameters_dir"/*.properties; do
        if [ -f "$param_file" ]; then
            # Extract resource type and unique identifier from the parameter file name
            base_name=$(basename "$param_file" .properties)
            resource_type=$(echo "$base_name" | cut -d '-' -f 1)
            unique_identifier=$(echo "$base_name" | cut -d '-' -f 2-)

            # Determine the corresponding template file
            template_file="Infrastructure/Templates/${resource_type}.yml"
            if [ ! -f "$template_file" ]; then
                echo "Error: Template file $template_file does not exist."
                continue
            fi

            # Create the stack name without duplicating resource_type
            stack_name="${APPLICATION_NAME}-${ENVIRONMENT_NAME}-${resource_type}"
            
            # Only append unique_identifier if it's not empty and not the same as resource_type
            if [ -n "$unique_identifier" ] && [ "$unique_identifier" != "$resource_type" ]; then
                stack_name="${stack_name}-${unique_identifier}"
            fi
            
            echo "Processing stack: $stack_name using $param_file"
            manage_resources "$stack_name" "$template_file" "$param_file"
        fi
    done
}

# Main Logic
handle_resources
if [ "$ACTION" == "create-changeset" ]; then
    echo "[END] Changesets created successfully."
elif [ "$ACTION" == "deploy" ]; then
    echo "[END] Deployment ran successfully."
else
    echo "Unsupported action: $ACTION"
    exit 1
fi
