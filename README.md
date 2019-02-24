export AWS_PROFILE=personal
git submodule add ssh://mortonprod@github.com/mortonprod/fe-personal-site modules/fe-personal-site
git submodule update --init
git submodule update --recursive --remote
terraform get --update=true

Will alway break on deletion since lambda needs time for cloud front to fully stop for it to work

terraform plan -var-file="variables.tfvar" --auto-approve
terraform apply -var-file="variables.tfvar" --auto-approve
