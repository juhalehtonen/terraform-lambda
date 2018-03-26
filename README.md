# Terraform with AWS Lambda -workflow

A simple Terraform configuration setup for AWS Lambda and a description of the proposed workflow.

## How to use

1. Install Terraform (On OSX you can just do `brew install terraform` if you trust Homebrew)
2. The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.
x.
y.
8. Run `terraform plan` to refresh the current state and to generate an action plan based on the config.
9. Run `terraform apply` to apply the plan and create resources.
10. Wait as Terraform provisions AWS Lambda for you.
11. Additionally, with `terraform graph` the plan can be visualized to show dependent ordering.

## Destroy changes

1. Run `terraform plan --destroy` to see what will happen when you initiate destroy.
2. Run `terraform destroy` and type `yes` to destroy the specified resources.
