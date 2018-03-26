/**
 * Configuration for the Terraform setup.
 *
 * This file exposes the variables available in main.tf. You should not need to touch
 * this, as the actual value definitions should be done in `terraform.tfvars`.
 */

# AWS authentication
variable "aws_access_key" {
  description = "Your AWS access key. Define in secrets.auto.tfvars."
  default = ""
}
variable "aws_access_secret" {
  description = "Your AWS secret key. Define in secrets.auto.tfvars."
  default = ""
}


# Lambda
variable "lambda_name" {
  description = "Name of the Lambda function."
  default = "ServerlessExample"
}

variable "lambda_region" {
  description = "Region for the AWS Lambda. Has to match the S3 region."
  default = "eu-central-1"
}

variable "lambda_runtime" {
  description = "Runtime for the AWS Lambda."
  default = "nodejs6.10"
}


# S3
variable "s3_bucket_name" {
  description = "Name of the S3 bucket."
}
variable "s3_bucket_key" {
  description = "Path and name of the file in S3 to use for the Lambda function."
  default = "v1.0.0/example.zip"
}
