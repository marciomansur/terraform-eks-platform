#!/bin/bash

export ACCOUNT_ID=""
export TF_BUCKET=$ACCOUNT_ID-tfstate

aws s3api create-bucket --bucket $TF_BUCKET --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1 > /dev/null 2>&1

aws s3api put-public-access-block --bucket $TF_BUCKET \
    --public-access-block-configuration=BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true > /dev/null 2>&1

aws s3api put-bucket-encryption --bucket $TF_BUCKET \
    --server-side-encryption-configuration '{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }
    ]
}' > /dev/null 2>&1

aws s3api put-bucket-versioning --bucket $TF_BUCKET --versioning-configuration Status=Enabled > /dev/null 2>&1

