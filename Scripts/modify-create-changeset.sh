#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

# Purpose:
# ----------
# This script dry-runs our deployment by creating a changeset for verification.

# Arguments:
# ----------
#   --environment-name        | Target environment where AWS resources will be created. 
#                             | Possible values: npd-dev, npd-st, ppd-customer, ppd-internal, prd-customer, prd-internal
#   --debug                   | Optional. true if you want to enable debug logging, false by default

echo "[START] Creating changesets started at $(date +"%d-%m-%Y %H:%M")"

ENVIRONMENT_NAME=""
DEBUG=false

while [ -n "$1" ]; do
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

# Function Definitions

create_changesets_for_npd_dev() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-internal.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-customer.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-npd-efs" "$EFS_TEMPLATE" "infrastructure/parameters/npd/efs.properties" "$CFN_ROLE_ARN"
}

create_changesets_for_npd_st() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-internal.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-customer.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-customer.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-internal.properties" "$CFN_ROLE_ARN"
}

create_changesets_for_ppd_customer() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" "$CFN_ROLE_ARN"
}

create_changesets_for_ppd_internal() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" "$CFN_ROLE_ARN"
}

create_changesets_for_prd_customer() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" "$CFN_ROLE_ARN"
}

create_changesets_for_prd_internal() {
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-wm-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-wm.properties" "$CFN_ROLE_ARN"
    create_update_change_set "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs.properties" "$CFN_ROLE_ARN"
}

# Main Logic

case "$ENVIRONMENT_NAME" in
    npd-dev)
        create_changesets_for_npd_dev ;;
    npd-st)
        create_changesets_for_npd_st ;;
    ppd-customer)
        create_changesets_for_ppd_customer ;;
    ppd-internal)
        create_changesets_for_ppd_internal ;;
    prd-customer)
        create_changesets_for_prd_customer ;;
    prd-internal)
        create_changesets_for_prd_internal ;;
    *)
        echo "Unsupported environment: $ENVIRONMENT_NAME"
        exit 1 ;;
esac

echo "[END] Changesets created successfully."
