locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  name = "${get_env("EX_APP_PREFIX")}-hello-dev"
}

unit "service" {
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/azure/container-instance-service"

  path = "service"

  values = {
    name     = local.name
    location = local.region_vars.locals.location

    // Microsoft's sample web server, pinned by digest, which answers every request with a welcome page
    image = "mcr.microsoft.com/azuredocs/aci-helloworld@sha256:456a1150aa41340a14c7be1342deda2cde9e6e7df9fde6b8a69de0ae04f92fad"
  }
}
