terraform {
  backend "s3" {
    # CAN SET THIS HERE ON IN MAKE FILE.
    bucket = "wgl-site-terraform-state"
    key    = "wgl-site"
    region = "eu-west-2"
    dynamodb_table = "wgl-site-terraform-state"
  }
}

provider "aws" {
  region      = "${var.aws_region}"
}

module "cloudfrontEdge-s3-module" {
  source = "modules/cloudfrontEdge-s3-module"
  name = "${var.name}"
  aws_region = "${var.aws_region}"
  domain_names = "${var.domain_names}"
  asset_folder = "${var.asset_folder}"
}


//////// SES

# resource "aws_api_gateway_rest_api" "api_gateway_rest_api" {
#   name        = "${var.name}"
#   description = "${var.name} description"
# }

# resource "aws_api_gateway_resource" "api_gateway_resource" {
#   rest_api_id = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
#   parent_id   = "${aws_api_gateway_rest_api.api_gateway_rest_api.root_resource_id}"
#   path_part   = "ses"
# }

# resource "aws_api_gateway_method" "api_gateway_method" {
#   rest_api_id = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
#   resource_id = "${aws_api_gateway_resource.api_gateway_resource.api_gateway_resource.id}"
#   http_method = "POST"
#   authorization = "NONE"
#   request_parameters = "${var.request_parameters}"
#   request_models = { "application/json" = "${var.request_model}" }
# }

# resource "aws_api_gateway_integration" "api_gateway_integration" {
#   rest_api_id = "${aws_api_gateway_rest_api.api_gateway_rest_api.id}"
#   resource_id = "${aws_api_gateway_resource.api_gateway_resource.api_gateway_resource.id}"
#   http_method = "${aws_api_gateway_method.api_gateway_method.http_method}"
#   type = "AWS"
#   uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_name}/invocations"
#   integration_http_method = "POST"
#   request_templates = { "application/json" = "${var.integration_request_template}" }
# }

# resource "aws_api_gateway_integration_response" "api_gateway_integration_response_200" {
#   rest_api_id = "${var.rest_api_id}"
#   resource_id = "${var.resource_id}"
#   http_method = "${aws_api_gateway_method.api_gateway_method.http_method}"
#   status_code = "${aws_api_gateway_method_response.ResourceMethod200.status_code}"
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin" = "'*'"
#   }
#   response_templates = { "application/json" = "${var.integration_response_template}" }
# }

# resource "aws_api_gateway_integration_response" "aws_api_gateway_integration_response_400" {
#   rest_api_id = "${var.rest_api_id}"
#   resource_id = "${var.resource_id}"
#   http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
#   status_code = "${aws_api_gateway_method_response.ResourceMethod400.status_code}"
#   response_templates = {
#     "application/json" = "${var.integration_error_template}"
#   }
#   response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
# }

# resource "aws_api_gateway_method_response" "ResourceMethod200" {
#   rest_api_id = "${var.rest_api_id}"
#   resource_id = "${var.resource_id}"
#   http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
#   status_code = "200"
#   response_models = { "application/json" = "${var.response_model}" }
#   response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "*" }
# }

# resource "aws_api_gateway_method_response" "ResourceMethod400" {
#   rest_api_id = "${var.rest_api_id}"
#   resource_id = "${var.resource_id}"
#   http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
#   status_code = "400"
#   response_models = { "application/json" = "Error" }
#   response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "*" }
# }