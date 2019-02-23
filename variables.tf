variable "name" {
  default = "maxwell-demon"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "domain_names" {
  description = "Only supports sub domain changes"
  default = ["test.alexandermorton.co.uk"]
}

variable "asset_folder" {
  description = "Only supports sub domain changes"
  default = "./modules/fe-personal-site/dist"
}


///SES


# variable "lambda_name" {}



# variable "account_id" {}

# variable "region" {}

# variable "integration_request_template" {
#   default = "{}"
# }

# variable "integration_response_template" {
#   default = "#set($inputRoot = $input.path('$')){}"
# }


# variable "request_parameters" {
#   default = {}
# }


# variable "request_model" {
#   default = "Empty"
# }


# variable "response_model" {
#   default = "Empty"
# }


# variable "integration_error_template" {
#   default = <<EOF
# #set ($errorMessageObj = $util.parseJson($input.path('$.errorMessage')) {
#   "message" : "$errorMessageObj.message"
# }
# EOF
# }

# variable "authorization" {
#   default = "NONE"
# }