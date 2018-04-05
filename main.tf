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


# 5) Create API Gateway :)
resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}

# All incoming requests to API Gateway must match with a configured resource and
# method in order to be handled.
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "{proxy+}" # Match any request path
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY" # allows any request method to be used
  authorization = "NONE"
}

# Each method on an API gateway resource has an integration which specifies
# where incoming requests are routed. Here we specify that requests to this
# method should be sent to the Lambda function.
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY" # will call the AWS Lambda API to create an "invocation" of the Lambda function.
  uri                     = "${aws_lambda_function.example.invoke_arn}"
}


# Unfortunately the proxy resource cannot match an empty path at the root of the
# API. To handle that, a similar configuration must be applied to the root
# resource that is built in to the REST API object.
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.example.invoke_arn}"
}

# Finally, we need to create an API Gateway "deployment" in order to activate
# the configuration and expose the API at a URL that can be used for testing:
resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  stage_name  = "test"
}

# By default any two AWS services have no access to one another, until access
# is explicitly granted. For Lambda functions, access is granted using the
# aws_lambda_permission resource:
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.example.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.example.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}"
}
