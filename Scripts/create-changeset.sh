#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

# Purpose:
# ----------
# This script dry-run our deployment by creating a changeset for verification.

# Arguments:
# ----------
#   Argument                | Description
#   environment-name        | Target environment where AWS resources will be created. 
#                           | Possible values: npd, nft, prd
#   debug                   | Optional. true if you want to enable debug logging, false by default

# Example Usage:
# ----------
# create-changeset.sh --environment-name npd --debug true

echo "[START] Creating changesets started at $(date +"%d-%m-%Y %H:%M")"

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

create_changesets_for_npd() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" 
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" 
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-secrets" "$SECRETS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/secrets.properties"
}

create_changesets_for_nft() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" 
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" 
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-secrets" "$SECRETS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/secrets.properties"
}

create_changesets_for_prd() {
    echo "No resource deployments defined: $ENVIRONMENT_NAME"
}

# Main Logic

case "$ENVIRONMENT_NAME" in
    npd)
        create_changesets_for_npd ;;
    nft)
        create_changesets_for_nft ;;
    prd)
        create_changesets_for_prd ;;
    *)
        echo "Unsupported environment: $ENVIRONMENT_NAME"
        exit 1 ;;
esac

echo "[END] Changesets ran successfully."
