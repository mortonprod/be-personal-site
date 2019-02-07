variable "name" {
  default = "maxwell-demon"
}
variable "aws_region" {
  default = "us-east-1"
}

variable "domain_names" {
  description = "Only supports sub domain changes"
  default = ["www.maxwells-demon.com", "maxwells-demon.com"]
}

variable "asset_folder" {
  description = "Only supports sub domain changes"
  default = "./modules/fe-personal-site/dist"
}
