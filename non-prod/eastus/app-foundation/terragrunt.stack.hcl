locals {
  // Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  // Also names the storage account and container registry, which are unique across all of Azure.
  name = "${get_env("EX_APP_PREFIX")}appdev"
}

stack "app" {
  // You'll typically want to pin this to a particular version of your catalog repo.
  // e.g.
  // source = "github.com/acme/terragrunt-infrastructure-catalog//stacks/azure/app-foundation?ref=v0.1.0"
  //
  // If you are using a private catalog, you may want to use an SSH source URL instead:
  // source = "git::git@github.com:acme/terragrunt-infrastructure-catalog.git//stacks/azure/app-foundation"
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//stacks/azure/app-foundation"

  path = "app"

  values = {
    name     = local.name
    location = local.region_vars.locals.location
  }
}
