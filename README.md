# Terraform with AWS Lambda and API Gateway

A simple Terraform configuration setup for AWS Lambda and a description of the proposed workflow.

## Before using

Keep in mind that this is an opinionated approach, as we ignore the built-in versioning and staged deployment mechanisms in AWS Lambda. Often these features are not necessary because changes can be tracked and deployed by keeping the Terraform configuration in a version-control repository.

If you think you will need to do something different or with a different architecture, you will need to adapt accordingly.

## How to use

1. Install Terraform (On OSX you can just do `brew install terraform` if you trust Homebrew)
2. The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.
3. Copy `secrets.auto.tfvars.sample` to `secrets.auto.tfvars` and configure your AWS access key and secret in it. Do NOT touch the sample file itself, as it is committed to version control for example purposes only.
4. Adjust the variables in to determine which version of the Lambda function to deploy, and which S3 bucket to use.
5. Move the required .zipped lambda function to the S3 bucket under the correct version-named directory
8. Run `terraform plan` to refresh the current state and to generate an action plan based on the config.
9. Run `terraform apply` to apply the plan and create resources.
10. Wait as Terraform provisions AWS Lambda for you.
11. Additionally, with `terraform graph` the plan can be visualized to show dependent ordering.

## Destroy changes

1. Run `terraform plan --destroy` to see what will happen when you initiate destroy.
2. Run `terraform destroy` and type `yes` to destroy the specified resources.

## Zip code for S3

```
cd lambda
zip ../example.zip main.js
```
