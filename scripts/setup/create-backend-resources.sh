#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Creates an AWS S3 Bucket for remote terraform state storage.
#           Intended for use with DynamoDB to support state locking and
#           consistency checking.
#
#           Managing the S3 and Backend config in the same file ensures
#           consistent bucket naming. S3 bucket = backend bucket. To guard
#           against errors, these should not be separated.
# -----------------------------------------------------------------------------
#  PREREQS: a) The bucket must exist before initializing the backend.
#           b)
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2018/12/09
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
: "${TF_VAR_stateBucket?  Whats the bucket name, bro?!}"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Setup Terraform state storage and locking
###---
printf '\n\n%s\n' "Provisioning state Storage and Locking mechnanism..."

aws configure set default.region "$TF_VAR_region"
echo "Region set to: $TF_VAR_region"


###---
### Setup Terraform state storage and locking
###---
tableExist="$(aws dynamodb describe-table --table-name "$stateLockDynamoDB" 2>/dev/null)"
if [[ -n "$tableExist" ]]; then
    pMsg "  We already have DynamoDB Table: $stateLockDynamoDB"
else
    pMsg "  Creating a DynamoDB table for state locking; ignore the above error..."
    aws dynamodb create-table --table-name "$stateLockDynamoDB" \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --sse-specification Enabled=true,SSEType=KMS
fi

printf '\n\n%s\n' "Creating a bucket for remote terraform state..."
# Bucket name must be unique to all bucket names
if ! aws s3 mb "s3://${TF_VAR_stateBucket}"; then
    pMsg "There was an issue creating the bucket: $TF_VAR_stateBucket"
    exit
else
    pMsg "  The bucket has been created: $TF_VAR_stateBucket"
fi

### Enable versioning
pMsg "  Enabling versioning..."
aws s3api put-bucket-versioning --bucket "$TF_VAR_stateBucket" \
    --versioning-configuration Status=Enabled

### Enable encryption
pMsg "  Enabling encryption..."
aws s3api put-bucket-encryption --bucket "$TF_VAR_stateBucket" \
    --server-side-encryption-configuration \
    '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

### Enable encryption
pMsg "  Blocking public access..."
aws s3api put-public-access-block --bucket "$TF_VAR_stateBucket" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"


###---
### Create the Terraform backend definition for this bucket
###---
scripts/setup/create-tf-backend.sh


###---
### Make the announcement
###---
printf '\n\n%s\n\n' "We're ready to start Terraforming!"


###---
### fin~
###---
exit 0
