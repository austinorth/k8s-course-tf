# k8s-course-tf
Terraform config for a simple 2 instance EC2 setup in AWS for [Linux Foundation
Kubernetes for
Developers (LFD259)](https://training.linuxfoundation.org/training/kubernetes-for-developers/) course labs.

## How to Use
### Set Up Dependencies
- [AWS CLI Credentials
  File](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [Terraform 11.13](https://www.terraform.io/downloads.html)
- An AWS VPC set up in your AWS account
- A subnet set up on that VPC.

### Set Up Variables
- `cp terraform.tfvars.example terraform.tfvars`
- Edit `terraform.tfvars` and fill out the variables specific to your
  environment. They are as follows:
  - `cidr_blocks` - the ip blocks you would like the instances to be
    accessible from.
  - `public_key` - the ssh public key you would like to use for
    connecting to the instance
  - `region` - the AWS region you would like to create the instances in
  - `subnet_id` - A subnet that you have previously set up in your VPC
    that you want to connect the instances to.
  - `username` - a unique username to identify resources as having been
    set up by you. This is useful for accounts where multiple people
    will be using this config to set up test environments.
  - `vpc_id` - the id of a VPC you've set up beforehand to deploy the
    instances to

### Deploy the Environment
- `terraform init` to intialize the Terraform provider
- `terraform plan` to see what will be created
- `terraform apply`, then type `yes` to send it on up!


### Optional Remote State
You can store the Terraform state remotely in an S3 bucket if you wish,
but it is not necessary unless you expect you'll be collaborating with
others on the same state. Do do this, create a `remote.tf` file in the
root of the repo. Be aware that this file is gitignored, so you can be
sure that your s3 bucket name and/or credentials you may decide to use
with it are not committed to repo.

```hcl
terraform {
  backend "s3" {
    bucket  = "terraform.mysite.private"
    key     = "k8s_practice_austin.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
```
