export AWS_REGION=${AWS_REGION:-"ap-southeast-2"}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"ap-southeast-2"}

APPLICATION_NAME=ccsa-doco-aws-infra
ENVIRONMENT_NAME=
DEBUG=false


S3_TEMPLATE=Infrastructure/Templates/S3/s3.yaml
EFS_TEMPLATE=infrastructure/templates/EFS/efs.yaml

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
