provider "aws" {
  region     = "${var.lambda_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


# 1) Archive file generation with Terraform :)
data "archive_file" "lambda" {
  type = "zip"
  source_file = "lambda/main.js"
  output_path = "lambda.zip"
}

# 2) Create S3 bucket :)
resource "aws_s3_bucket" "example" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
}

# 3) Uploading a bucket object to S3 :)
resource "aws_s3_bucket_object" "object" {
  key    = "${var.s3_bucket_key}" # The name of the object once its in the bucket
  bucket = "${aws_s3_bucket.example.id}"
  source = "${data.archive_file.lambda.output_path}"
  etag   = "${md5(file("${data.archive_file.lambda.output_path}"))}" # Used to trigger updates
}


# 4) Create the AWS Lambda from the archive in S3 :)
resource "aws_lambda_function" "example" {
  function_name = "${var.lambda_name}"

  # Change these to reference the things defined by our created resource
  s3_bucket = "${aws_s3_bucket.example.id}"
  s3_key    = "${aws_s3_bucket_object.object.id}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "${var.lambda_runtime}"

  # IAM role which dictates what other AWS services the Lambda function may access.
  role = "${aws_iam_role.lambda_exec.arn}"
}


# IAM role which dictates what other AWS services the Lambda function may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = "${file("policies/lambda-role.json")}"
}
