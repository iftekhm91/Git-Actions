#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/common.sh"

# Purpose:
# ----------
# This script deploys the infrastructure resources for DCTM.

# Arguments:
# ----------
#   Argument                | Description
#   environment-name        | Target environment where AWS resources will be created. 
#                           | Possible values: npd-dev, npd-st, ppd-customer, ppd-internal, prd-customer, prd-internal
#   debug                   | Optional. true if you want to enable debug logging, false by default

# Example Usage:
# ----------
# deploy.sh --environment-name npd-dev --debug true

echo "[START] Deploying stacks started at $(date +"%d-%m-%Y %H:%M")"

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

# S3 Deployment for doco
if [[ "$ENVIRONMENT_NAME" = npd-* ]]; then
    # NPD [ DEV - ST ] - INTERNAL
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-internal-s3" "$S3_TEMPLATE" "Infrastructure/Parameters/${ENVIRONMENT_NAME}/s3-internal.properties" 
    # NPD [ DEV - ST ] - CUSTOMER
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-customer-s3" "$S3_TEMPLATE" "Infrastructure/parameters/${ENVIRONMENT_NAME}/s3-customer.properties" 
else
    deploy "${APPLICATION_NAME}-${ENVIRONMENT_NAME}-s3" "$S3_TEMPLATE" "infrastructure/parameters/${ENVIRONMENT_NAME}/s3.properties" 
fi;
