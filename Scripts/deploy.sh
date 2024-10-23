#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

# Purpose:
# ----------
# This script deploys the infrastructure resources for Testing.

# Arguments:
# ----------
#   Argument                | Description
#   environment-name        | Target environment where AWS resources will be created. 
#                           | Possible values: npd, nft, prd
#   debug                   | Optional. true if you want to enable debug logging, false by default

# Example Usage:
# ----------
# deploy.sh --environment-name npd --debug true

ENVIRONMENT_NAME=
DEBUG=false

while [ -n "$1" ]
do
    case "$1" in
        --environment-name)
            ENVIRONMENT_NAME=$2
            shift ;;
        --debug)
            DEBUG=$2
            shift ;;
        *)
            echo "$1 is not an option"
            exit 1 ;;
    esac
    shift
done

if [ -z "$ENVIRONMENT_NAME" ]; then
    echo "Error: environment-name is required"
    exit 1
fi 

deploy_resources_for_npd() {
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-secrets" "$SECRETS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/secrets.properties"
}

deploy_resources_for_nft() {
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-secrets" "$SECRETS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/secrets.properties"
}

deploy_resources_for_prd() {
    echo "No resource deployments defined: $ENVIRONMENT_NAME"
}

# Main Logic

case "$ENVIRONMENT_NAME" in
    npd)
        deploy_resources_for_npd ;;
    nft)
        deploy_resources_for_nft ;;
    prd)
        deploy_resources_for_prd ;;
    *)
        echo "Unsupported environment: $ENVIRONMENT_NAME"
        exit 1 ;;
esac

echo "[END] Deployment ran successfully."
