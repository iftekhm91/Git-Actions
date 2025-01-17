name: Deploy Infrastructure
run-name: ${{ github.workflow }} on ${{ github.ref_name }} triggered by ${{ github.actor }}

on:
  push:
    branches:
      - npd
      - nft
      - prd

permissions:
  id-token: write
  contents: read

jobs:
  Create-Changeset:
    runs-on: default
    environment: test-create-changeset
    outputs:
      ACCOUNT_ID: ${{ steps.set-env.outputs.ACCOUNT_ID }}
      DEPLOY_ROLE: ${{ steps.set-env.outputs.DEPLOY_ROLE }}
      TRUST_ROLE: ${{ steps.set-env.outputs.TRUST_ROLE }}
      REGION: ${{ steps.set-env.outputs.REGION }}
      BRANCH_NAME: ${{ steps.set-env.outputs.BRANCH_NAME }}
    steps:
      - name: Check out repository code
        uses: actions/checkout@v4

      - name: Set Environment Variables
        id: set-env
        run: |
          # Create a JSON object mapping branch names to environment variables
          ENV_VARS='{
            "npd": {
              "ACCOUNT_ID": "${{ vars.AWS_ACCOUNT_ID_NPD }}",
              "DEPLOY_ROLE": "${{ vars.AWS_DEPLOY_ROLE_COMMON }}",
              "TRUST_ROLE": "${{ vars.AWS_TRUST_ROLE_COMMON }}",
              "REGION": "${{ vars.AWS_REGION_COMMON }}"
            },
            "nft": {
              "ACCOUNT_ID": "${{ vars.AWS_ACCOUNT_ID_NFT }}",
              "DEPLOY_ROLE": "${{ vars.AWS_DEPLOY_ROLE_COMMON }}",
              "TRUST_ROLE": "${{ vars.AWS_TRUST_ROLE_COMMON }}",
              "REGION": "${{ vars.AWS_REGION_COMMON }}"
            },           
            "prd": {
              "ACCOUNT_ID": "${{ vars.AWS_ACCOUNT_ID_PRD }}",
              "DEPLOY_ROLE": "${{ vars.AWS_DEPLOY_ROLE_COMMON }}",
              "TRUST_ROLE": "${{ vars.AWS_TRUST_ROLE_COMMON}}",
              "REGION": "${{ vars.AWS_REGION_COMMON }}"
            }
          }'

          # Get the current branch name without 'refs/heads/'
          BRANCH_NAME=$(echo "${{ github.ref }}" | sed 's|refs/heads/||')         

          # Extract environment variables from the JSON based on the branch
          ACCOUNT_ID=$(echo $ENV_VARS | jq -r --arg branch "$BRANCH_NAME" '.[$branch].ACCOUNT_ID')
          DEPLOY_ROLE=$(echo $ENV_VARS | jq -r --arg branch "$BRANCH_NAME" '.[$branch].DEPLOY_ROLE')
          TRUST_ROLE=$(echo $ENV_VARS | jq -r --arg branch "$BRANCH_NAME" '.[$branch].TRUST_ROLE')
          REGION=$(echo $ENV_VARS | jq -r --arg branch "$BRANCH_NAME" '.[$branch].REGION')

          # Set job outputs using GITHUB_OUTPUT
          echo "ACCOUNT_ID=${ACCOUNT_ID}" >> $GITHUB_OUTPUT
          echo "DEPLOY_ROLE=${DEPLOY_ROLE}" >> $GITHUB_OUTPUT
          echo "TRUST_ROLE=${TRUST_ROLE}" >> $GITHUB_OUTPUT
          echo "REGION=${REGION}" >> $GITHUB_OUTPUT
          echo "BRANCH_NAME=${BRANCH_NAME}" >> $GITHUB_OUTPUT


      - name: Environment to Deploy
        run: |
          echo "Environment being used for this deployment:"
          echo "ENVIRONMENT NAME: ${{ steps.set-env.outputs.BRANCH_NAME }}"
          echo "ACCOUNT ID: ${{ steps.set-env.outputs.ACCOUNT_ID }}"
          echo "DEPLOY ROLE: ${{ steps.set-env.outputs.DEPLOY_ROLE }}"
          echo "TRUST ROLE: ${{ steps.set-env.outputs.TRUST_ROLE }}"
          echo "REGION: ${{ steps.set-env.outputs.REGION }}"
          echo "=============================="


      - name: Assume CICD Role
        uses: CBA-General/rrcs-common-actions/cs-aws-assume-deploy-role@main
        with:
          workload-account-id: ${{ steps.set-env.outputs.ACCOUNT_ID }}
          workload-deploy-role: ${{ steps.set-env.outputs.DEPLOY_ROLE }}
          github-trust-role: ${{ steps.set-env.outputs.TRUST_ROLE }}
          aws-region: ${{ steps.set-env.outputs.REGION }}

      - name: whoami
        run: aws sts get-caller-identity

      - name: Create Changeset
        run: |
          chmod +x scripts/create-changeset.sh
          scripts/create-changeset.sh --environment-name ${{ steps.set-env.outputs.BRANCH_NAME }} --debug true


  Deploy-Changeset:
    needs: Create-Changeset
    runs-on: default
    environment: test-deploy-changeset
    steps:
      - name: Changeset Approval 
        run: echo "The Changeset has been approved, proceeding to Deploy Changeset."
      
      - name: Check Environment Variables
        run: |
          echo "ACCOUNT_ID: ${{ needs.Create-Changeset.outputs.ACCOUNT_ID }}"
          echo "DEPLOY_ROLE: ${{ needs.Create-Changeset.outputs.DEPLOY_ROLE }}"
          echo "TRUST_ROLE: ${{ needs.Create-Changeset.outputs.TRUST_ROLE }}"
          echo "REGION: ${{ needs.Create-Changeset.outputs.REGION }}"

      - name: Check out repository code
        uses: actions/checkout@v4

      - name: Assume CICD Role
        uses: CBA-General/rrcs-common-actions/cs-aws-assume-deploy-role@main
        with:
          workload-account-id: ${{ needs.Create-Changeset.outputs.ACCOUNT_ID }}
          workload-deploy-role: ${{ needs.Create-Changeset.outputs.DEPLOY_ROLE }}
          github-trust-role: ${{ needs.Create-Changeset.outputs.TRUST_ROLE }}
          aws-region: ${{ needs.Create-Changeset.outputs.REGION }}

      - name: whoami
        run: aws sts get-caller-identity

      - name: Deploy Infra
        run: |
          chmod +x scripts/deploy.sh
          echo "Deploying the changeset"
          scripts/deploy.sh --environment-name ${{ needs.Create-Changeset.outputs.BRANCH_NAME }} --debug true
