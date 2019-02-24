export AWS_PROFILE=personal
git submodule add ssh://mortonprod@github.com/mortonprod/fe-personal-site modules/fe-personal-site
git submodule update --init
git submodule update --recursive --remote
terraform get --update=true

Will alway break on deletion since lambda needs time for cloud front to fully stop for it to work

terraform plan -var-file="variables.tfvar" --auto-approve
terraform apply -var-file="variables.tfvar" --auto-approve

# Issue
Must verify email first.
Fix inline css issue
Fix cross browser.
SES only works for api requests not from domain.
Fix domain name acm setting issue: Always select first domain


## CORS

This done outside terraform.

Create OPTIONS method
Add 200 Method Response with Empty Response Model to OPTIONS method
Add Mock Integration to OPTIONS method
Add 200 Integration Response to OPTIONS method
Add Access-Control-Allow-Headers, Access-Control-Allow-Methods, Access-Control-Allow-Origin Method Response Headers to OPTIONS method
Add Access-Control-Allow-Headers, Access-Control-Allow-Methods, Access-Control-Allow-Origin Integration Response Header Mappings to OPTIONS method
Add Access-Control-Allow-Origin Method Response Header to POST method
Add Access-Control-Allow-Origin Integration Response Header Mapping to POST method 
