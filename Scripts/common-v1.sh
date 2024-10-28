export AWS_REGION=${AWS_REGION:-"ap-southeast-2"}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"ap-southeast-2"}

APPLICATION_NAME=ccsa-ga-test-aws-infra
ENVIRONMENT_NAME=
DEBUG=false


S3_TEMPLATE=infrastructure/templates/s3.yml
EFS_TEMPLATE=infrastructure/templates/efs.yml
SECRETS_TEMPLATE=infrastructure/templates/secrets.yml

# TODO merge below two functions later
create_update_change_set () {
    local STACK_NAME=$1
    local STACK_TEMPLATE=$2
    local STACK_PARAMETERS=$3
    local CFN_ROLE_ARN=$4

    aws cloudformation deploy \
        --no-execute-changeset \
        --no-fail-on-empty-changeset \
        --stack-name $STACK_NAME \
        --template-file $STACK_TEMPLATE \
        --parameter-overrides $(cat $STACK_PARAMETERS)
}

deploy () {
    local STACK_NAME=$1
    local STACK_TEMPLATE=$2
    local STACK_PARAMETERS=$3
    local CFN_ROLE_ARN=$4

    aws cloudformation deploy \
        --no-fail-on-empty-changeset \
        --stack-name $STACK_NAME \
        --template-file $STACK_TEMPLATE \
        --parameter-overrides $(cat $STACK_PARAMETERS)
}
