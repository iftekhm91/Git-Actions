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

echo "[START] Infrastructure management started at $(date +"%d-%m-%Y %H:%M")"

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

# Function to create/update change set
create_update_change_set () {
    local STACK_NAME=$1
    local STACK_TEMPLATE=$2
    local STACK_PARAMETERS=$3
    local CFN_ROLE_ARN=$4

    aws cloudformation deploy \
        --no-execute-changeset \
        --no-fail-on-empty-changeset \
        --stack-name "$STACK_NAME" \
        --template-file "$STACK_TEMPLATE" \
        --parameter-overrides $(cat "$STACK_PARAMETERS")
}

# Function to deploy resources
deploy () {
    local STACK_NAME=$1
    local STACK_TEMPLATE=$2
    local STACK_PARAMETERS=$3
    local CFN_ROLE_ARN=$4

    aws cloudformation deploy \
        --no-fail-on-empty-changeset \
        --stack-name "$STACK_NAME" \
        --template-file "$STACK_TEMPLATE" \
        --parameter-overrides $(cat "$STACK_PARAMETERS")
}

# Function to create changesets dynamically
create_changesets() {
    local template_dir="Infrastructure/Templates"
    local parameters_dir="Infrastructure/Parameters/${ENVIRONMENT_NAME}"

    if [ ! -d "$parameters_dir" ]; then
        echo "Error: Parameters directory for environment $ENVIRONMENT_NAME does not exist."
        exit 1
    fi

    for template in "$template_dir"/*; do
        template_name=$(basename "$template")
        param_file="${parameters_dir}/${template_name//.yml/.properties}"

        if [ -f "$param_file" ]; then
            create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-${template_name%.*}" "$template" "$param_file"
        else
            echo "Warning: Parameter file $param_file does not exist for template $template_name"
        fi
    done
}

# Function to deploy resources dynamically
deploy_resources() {
    local template_dir="Infrastructure/Templates"
    local parameters_dir="Infrastructure/Parameters/${ENVIRONMENT_NAME}"

    if [ ! -d "$parameters_dir" ]; then
        echo "Error: Parameters directory for environment $ENVIRONMENT_NAME does not exist."
        exit 1
    fi

    for template in "$template_dir"/*; do
        template_name=$(basename "$template")
        param_file="${parameters_dir}/${template_name//.yml/.properties}"

        if [ -f "$param_file" ]; then
            deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-${template_name%.*}" "$template" "$param_file"
        else
            echo "Warning: Parameter file $param_file does not exist for template $template_name"
        fi
    done
}

# Main Logic
case "$ACTION" in
    create-changeset)
        create_changesets
        echo "[END] Changesets created successfully."
        ;;
    deploy)
        deploy_resources
        echo "[END] Deployment ran successfully."
        ;;
    *)
        echo "Unsupported action: $ACTION"
        exit 1 ;;
esac
