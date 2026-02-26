terraform {
  backend "s3" {
    bucket         = "wgl-site-terraform-state"
    key            = "wgl-site"
    region         = "eu-west-2"
    dynamodb_table = "wgl-site-terraform-state"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "cloudfrontEdge-s3-module" {
  source       = "./modules/cloudfrontEdge-s3-module"
  name         = "${var.name}"
  aws_region   = "${var.aws_region}"
  domain_names = "${var.domain_names}"
  asset_folder = "${var.asset_folder}"
}

data "archive_file" "file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "role" {
  name = "sesRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "policy" {
  name        = "SES"
  description = "SES"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendEmail",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "ses"
  role             = "${aws_iam_role.role.arn}"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  reserved_concurrent_executions = 1
  source_code_hash = "${data.archive_file.file.output_base64sha256}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
  name        = "${var.name}"
  description = "${var.name} description"
}

resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id}"
  path_part   = "ses"
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id        = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
  resource_id        = "${aws_api_gateway_resource.api_gateway_resource.id}"
  http_method        = "POST"
  authorization      = "${var.authorization}"
  request_parameters = "${var.request_parameters}"

  request_models = {
    "application/json" = "${var.request_model}"
  }
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
  resource_id             = "${aws_api_gateway_resource.api_gateway_resource.id}"
  http_method             = "${aws_api_gateway_method.api_gateway_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"

  integration_http_method = "POST"

}

resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
    resource_id   = "${aws_api_gateway_resource.api_gateway_resource.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
    resource_id   = "${aws_api_gateway_resource.api_gateway_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}
resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
    resource_id   = "${aws_api_gateway_resource.api_gateway_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    type          = "MOCK"
    request_templates = { "application/json" = "${var.integration_request_template}" }
    depends_on = [aws_api_gateway_method.options_method]
}
resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
    resource_id   = "${aws_api_gateway_resource.api_gateway_resource.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [aws_api_gateway_integration.options_integration]
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
  stage_name  = "prod"
}

data "aws_acm_certificate" "acm_certificate" {
  domain   = "${element(split(".", var.domain_names[0]),0) != "" ? replace(var.domain_names[0],"${element(split(".", var.domain_names[0]),0)}.", "") : replace(var.domain_names[0], "/(^)[.]/", "")}"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "example" {
  certificate_arn = "${data.aws_acm_certificate.acm_certificate.arn}"
  domain_name     = "ses.${element(split(".", var.domain_names[0]),0) != "" ? replace(var.domain_names[0],"${element(split(".", var.domain_names[0]),0)}.", "") : replace(var.domain_names[0], "/(^)[.]/", "")}"
}

resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
  stage_name  = "${aws_api_gateway_deployment.example.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.example.domain_name}"
}

data "aws_route53_zone" "route53_zone" {
  name = "${element(split(".", var.domain_names[0]),0) != "" ? replace(var.domain_names[0],"${element(split(".", var.domain_names[0]),0)}.", "") : replace(var.domain_names[0], "/(^)[.]/", "")}"
}

resource "aws_route53_record" "example" {
  name    = "${aws_api_gateway_domain_name.example.domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.route53_zone.id}"

  alias {
    evaluate_target_health = true
    name                   = "${aws_api_gateway_domain_name.example.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.example.cloudfront_zone_id}"
  }
}