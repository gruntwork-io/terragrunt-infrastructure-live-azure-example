locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  name = "${get_env("EX_APP_PREFIX")}-hello-dev"
}

unit "website" {
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/azure/static-website"

  path = "website"

  values = {
    name     = local.name
    location = local.region_vars.locals.location
  }
}
