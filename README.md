# Terraform EKS Platform

A terraform module for orchestrating the lifecycle (creation, updating, termination) of a platform based on EKS (Elastic Kubernetes Service) from AWS.

## Architecture

Session for explaining solutions architecture

## Prerequisites

Before start using the module, some initial configuration is required.

### Tools

- Terraform 0.12.23+
- Access to AWS accounts
- kubectl
- AWS CLI

### Configure terraform backend: tfstate S3 bucket

Everything in Terraform starts with state. If there's more than one engineer working on terraform, the remote state guarantees the configuration is shared between all peers.
 
If you're just running terraform to an existing environment, then you can jump this step. If you are creating a new account from scratch, then, the first thing you need to do is create a new S3 bucket following the instruction:

```
export TF_BUCKET=$ACCOUNT_ID-tfstate
aws s3api create-bucket --bucket $TF_BUCKET --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1 > /dev/null 2>&1
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
```

Or, just go to S3 console and create the bucket from there. Follow the name pattern, replacing `$ACCOUNT_ID` with your AWS account ID. This is useful because S3 is a global service,
so the prefix creates an unique bucket, and works even you're using different accounts.

**Note:** Make sure to enable **AES256** Server-Side Encryption as well as the recommended value for public access to the bucket
and object.

### Configure terraform backend: DynamoDB lock table

As there are multiple engineers working on Terraform, we need a way to lock concurrent `terraform plan` and `terraform apply`. For that Terraform use a DynamoDB table to lock access to the current Terraform State. To create this table, go to the DynamoDB console in AWS and create a new table with the following attributes:

- Table name: `$ACCOUNT_ID-tfstate-lock`
- Primary key: `LockID` as String type
- Don't need to add a sort key

Wait a bit while your table is being created.

And you're now ready to start deploying with Terraform!
    
## Project layout

 This project uses a modular approach, which means you can use the same set of Terraform modules and Kubernetes manifests for all environments, with some different set of configurations.
 Before creating a new env or modifying an existing one:
 
 - `/environments` - Terraform module to create required resources for that account (IAM, S3, etc);
 - `/kubernetes` - Contains Terraform modules to configure clusters
 - `/modules` - Create resources required before cluster creation (e.g. VPC, subnets, etc);
   - `/platform` - Create resources that are required to run a Kubernetes cluster (EBS, EC2 instances, etc);
 
  
## Running the setup for environment

If you're creating a new env (even in another repo), click here. To run the modules and to create a new environment, follow the next steps.

### Terraform part

The objective is to manage resources for each environment:

```bash
cd environments/$ENV
terraform init
terraform plan -var-file='config/variables.tfvars' -out=tfplan
terraform apply tfplan
```

And you're done! After waiting for a while until Terraform can spawn every resource, you will have an up and running cluster in AWS. 

Terraform will generate the kubeconfig for you to access your cluster using `kubectl`. In order to use it correctly, run:

```bash
terraform output cluster_kubeconfig >> ~/.kube/contexts/$CLUSTER_NAME.yml
export KUBECONFIG=~/.kube/contexts/$CLUSTER_NAME.yml
```

By doing this, you make sure you can access multiple clusters with different contexts.


