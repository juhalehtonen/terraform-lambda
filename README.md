# Terraform with AWS Lambda

A simple Terraform configuration setup for AWS Lambda and a description of the proposed workflow.

## Before using

Keep in mind that this is an opinionated approach, as we ignore the built-in versioning and staged deployment mechanisms in AWS Lambda. Often these features are not necessary because changes can be tracked and deployed by keeping the Terraform configuration in a version-control repository.

If you think you will need to do something different or with a different architecture, you will need to adapt accordingly.

## How to use

Note that this currently only creates the Lambda and the required role to run it. 

0. Create a release (manually) with `cd lambda && zip ../example.zip main.js`
1. Move the .zip to S3 bucket under the correct version-named directory
2. Install Terraform (On OSX you can just do `brew install terraform` if you trust Homebrew)
3. The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.
4. Copy `secrets.auto.tfvars.sample` to `secrets.auto.tfvars` and configure your AWS access key and secret in it. Do NOT touch the sample file itself, as it is committed to version control for example purposes only.
5. Adjust the variables in `terraform.tfvars` to determine which version of the Lambda function to deploy, and which S3 bucket to use.
6. Run `terraform plan` to refresh the current state and to generate an action plan based on the config.
7. Run `terraform apply` to apply the plan and create resources.
8. Wait as Terraform provisions AWS Lambda for you.
9. Additionally, with `terraform graph` the plan can be visualized to show dependent ordering.

## Destroy changes

1. Run `terraform plan --destroy` to see what will happen when you initiate destroy.
2. Run `terraform destroy` and type `yes` to destroy the specified resources.

## Test with AWS CLI

You can invoke this with the following command to ensure everything works:

`aws lambda invoke --region=eu-central-1 --function-name=ServerlessExample output.txt`


## To-do

- Creation of S3?
- API Gateway creation?
- CI setup for creating the release artifacts (zip file)?
