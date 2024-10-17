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
#                           | Possible values: npd-dev, npd-st, ppd-customer, ppd-internal, prd-customer, prd-internal
#   debug                   | Optional. true if you want to enable debug logging, false by default

# Example Usage:
# ----------
# deploy.sh --environment-name npd-dev --debug true

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

deploy_changesets_for_npd_dev() {
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-internal.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3-customer.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-internal.properties" 
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-efs" "$EFS_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/efs-customer.properties" 
}

deploy_changesets_for_npd_st() {
    echo "No resource deployments defined"
}

deploy_changesets_for_ppd_customer() {
   echo "No resource deployments defined"
}

deploy_changesets_for_ppd_internal() {
    echo "No resource deployments defined"
}

deploy_changesets_for_prd_customer() {
   echo "No resource deployments defined"
}

deploy_changesets_for_prd_internal() {
    echo "No resource deployments defined"
}

# Main Logic

case "$ENVIRONMENT_NAME" in
    npd-dev)
        deploy_changesets_for_npd_dev ;;
    npd-st)
        deploy_changesets_for_npd_st ;;
    ppd-customer)
        deploy_changesets_for_ppd_customer ;;
    ppd-internal)
        deploy_changesets_for_ppd_internal ;;
    prd-customer)
        deploy_changesets_for_prd_customer ;;
    prd-internal)
        deploy_changesets_for_prd_internal ;;
    *)
        echo "Unsupported environment: $ENVIRONMENT_NAME"
        exit 1 ;;
esac

echo "[END] Changesets created successfully."
