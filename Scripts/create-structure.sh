#!/bin/bash

# Define environments
environments=("npd-dev" "npd-st" "ppd-customer" "ppd-internal" "prd-customer" "prd-internal")

# Define resource types
resources=("S3" "EFS" "Backups" "Secrets")

# Create the main infrastructure structure
mkdir -p Infrastructure/Templates

# Create resource directories and corresponding YAML files
for resource in "${resources[@]}"; do
  mkdir -p "Infrastructure/Templates/$resource"
  
  # Create the corresponding YAML file with the correct lowercase name
  case $resource in
    S3)   touch "Infrastructure/Templates/$resource/s3.yml" ;;
    EFS)  touch "Infrastructure/Templates/$resource/efs.yml" ;;
    Backups) touch "Infrastructure/Templates/$resource/backups.yml" ;;
    Secrets) touch "Infrastructure/Templates/$resource/secrets.yml" ;;
  esac
done

# Create Parameters directory and environment-specific parameter files for each resource
mkdir -p Infrastructure/Parameters

for env in "${environments[@]}"; do
  mkdir -p "Infrastructure/Parameters/$env"
  
  # Create parameter files for each resource in the environment directory
  for resource in "${resources[@]}"; do
    case $resource in
      S3)   touch "Infrastructure/Parameters/$env/s3-parameters.properties" ;;
      EFS)  touch "Infrastructure/Parameters/$env/efs-parameters.properties" ;;
      Backups) touch "Infrastructure/Parameters/$env/backups-parameters.properties" ;;
      Secrets) touch "Infrastructure/Parameters/$env/secrets-parameters.properties" ;;
    esac
  done
done

# Additional folder structure as specified
mkdir -p Infrastructure/Templates/S3
touch Infrastructure/Templates/S3/s3.yml

mkdir -p Infrastructure/Templates/EFS
touch Infrastructure/Templates/EFS/efs.yml

mkdir -p Infrastructure/Templates/Backups
touch Infrastructure/Templates/Backups/backups.yml

mkdir -p Infrastructure/Templates/Secrets
touch Infrastructure/Templates/Secrets/secrets.yml

echo "Complete directory structure and files created successfully!"

