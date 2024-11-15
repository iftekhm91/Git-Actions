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
#                           | Possible values: npd-dev, npd-st, ppd-customer, ppd-internal, prd-customer, prd-internal
#   debug                   | Optional. true if you want to enable debug logging, false by default

# Example Usage:
# ----------
# create-changeset.sh --environment-name npd-dev --debug true

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

# Define environments where Dctm-Wm S3 and EFS stacks should be included

WM_S3_DEPLOY_ENVIRONMENTS=("npd-dev" "npd-st" "ppd-customer" "prd-customer")
WM_EFS_DEPLOY_ENVIRONMENTS=("npd-dev" "npd-st" "ppd-customer" "prd-customer")


# S3 CHANGESET CREATION for Dctm-Wm
if [[ " ${WM_S3_DEPLOY_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT_NAME} " ]]; then
    # Create changeset for S3 Dctm-Wm
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
fi

# S3 CHANGESET CREATION for Dctm
if [[ "$ENVIRONMENT_NAME" = npd-* ]]; then
    # NPD [ DEV - ST ] - INTERNAL
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-internal.properties" "$CFN_ROLE_ARN"
    # NPD [ DEV - ST ] - CUSTOMER
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-customer.properties" "$CFN_ROLE_ARN"
else
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" "$CFN_ROLE_ARN"
fi;

# EFS CHANGESET CREATION for Dctm-Wm
if [[ " ${WM_EFS_DEPLOY_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT_NAME} " ]]; then
    # Create changeset for EFS Dctm-Wm
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
fi

# EFS CHANGESET CREATION for Dctm
if [[ "$ENVIRONMENT_NAME" = npd-* ]]; then
    create_update_change_set "${APPLICATION_NAME}-npd-efs" "$EFS_TEMPLATE" "infrastructure/parameters/npd/efs.properties" "$CFN_ROLE_ARN"
else
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" "$CFN_ROLE_ARN"

fi;

# EFS CHANGESET CREATION for Dctm in ST
if [[ "$ENVIRONMENT_NAME" = npd-st ]]; then
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-customer.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-internal.properties" "$CFN_ROLE_ARN"
fi;
