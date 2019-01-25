export AWS_PROFILE=personal
git submodule add ssh://mortonprod@github.com/mortonprod/fe-personal-site modules/fe-personal-site
git submodule update --init
git submodule update --recursive --remote
terraform get --update=true