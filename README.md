# Terraform EKS Platform

A terraform module for orchestrating the lifecycle (creation, updating, termination) of a platform based on EKS (Elastic Kubernetes Service) from AWS.

## Architecture

To explore the solution architecture, click [here](docs/system-architecture.md)

## Prerequisites

Before start using the module, some initial configuration is required.

### Tools

- [Terraform 0.12.23+](https://www.terraform.io/downloads.html)
- Access to an AWS account
- [AWS CLI](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Authenticate to AWS

The following steps requires access to AWS. You can follow [this](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html) tutorial to set up an IAM user for development needs.
With the AWS CLI, run:

```bash
aws configure
```

It'll create a new profile under your `~/.aws` folder, with your credentials. You can set different profiles and choose which one to work. Follow [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) tutorial.

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
 
 - `/environments` - Which environment to deploy and configure your setup;
   - `/config` - Contains the raw configuration to run the Terraform modules;
   - `/services` - Contains information to run the services in Kubernetes cluster;
 - `/kubernetes` - Contains all Kubernetes resources to start a cluster, such as Ingress Controller;
 - `/modules` - Terraform modules that can be used in many different places;
   - `/platform` - Create resources for network, external ingress and EKS configuration;
 
  
## Running the setup for environment

To run the modules and to create a new environment, follow the next steps.

NOTE: Your public domain needs to have a hosted zone already created. If your registrar is somewhere else than Route53, make sure to add the NS records from your AWS hosted zone into your DNS configuration. Terraform won't be able to issue certificates or configure ALB ingress otherwise.

### Step 1: Terraform

The objective is to manage resources for each environment:

```bash
cd environments/$ENV
terraform init
terraform plan -var-file='config/variables.tfvars' -out=tfplan
terraform apply tfplan
```

And you're done! After waiting for a while until Terraform can spin up every resource, you will have an up and running cluster in AWS.

Terraform will generate the kubeconfig for you to access your cluster using `kubectl`. In order to use it correctly, run:

```bash
terraform output cluster_kubeconfig >> ~/.kube/contexts/$CLUSTER_NAME.yml
export KUBECONFIG=~/.kube/contexts/$CLUSTER_NAME.yml
```

By doing this, you make sure you can access multiple clusters with different contexts.


### Step 2: Kubernetes initial config

With your cluster up and running and your kubectl context point to the new cluster, you're ready to proceed.
Before doing anything else, add the labels to your nodes, so the master knows where to manage the pods from your deployments:

```bash
kubectl get nodes
kubectl label nodes <node-name> clusterLayer=app
kubectl label nodes <node-name> clusterLayer=db
```

As of now, this step is not yet automated, so you will need to check on AWS console which nodes belongs to which subnet.

Now, deploy the initial config by running:

```bash
kubectl apply -f kubernetes/
```

Wait a little until the your pods status is `Ready`.

### Step 3: Kubernetes deployments

With your cluster configured, you can now proceed to deploy your services. Each service has a different set of configurations for each environment. To run everything, just do:

```bash
kubectl apply -f environments/$ENV/services/
```

Try to reach your application at: `webapp.{env}.{public_domain}`

## Improvements and next steps

The solution needs some improvements to be used as a production setup:

- There's a lot of manual steps, and some of them could lead to a total failure at creating a new environment. A wrapper around the solution is a good idea, this way, we can  reduce the number of steps and do more imperative checks.
Another good suggestion is to use something like [Argo](https://argoproj.github.io/) to create a workflow and manage configuration;
- This whole solution can be containerized, so the dependencies can be managed better;
- The `/services` part can be abstracted. Some configurations won't change often, just environmental changes. A tool like [Kustomize](https://kustomize.io/) or [Helm](https://helm.sh/) could be useful to create packages and automate the deployment;
- Helm can also be used to manage cluster dependencies;
- The process of deployment requires manual work. A CI/CD tool is required to create some hooks and automate deployments and tests.
- The Terraform module can be extensible for multiple private subnets, and it should also support peering and VPN access.
