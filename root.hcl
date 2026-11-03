# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for OpenTofu/Terraform that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load subscription-level variables
  subscription_vars = read_terragrunt_config(find_in_parent_folders("subscription.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  subscription_id = local.subscription_vars.locals.subscription_id
  location        = local.region_vars.locals.location

  # Storage account names are unique across all of Azure, so state names start with this prefix
  app_prefix = get_env("EX_APP_PREFIX")
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  # Only this subscription may be operated on by this template
  subscription_id = "${local.subscription_id}"
  features {}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an Azure Storage account, one per subscription and region.
#
# Storage account names are unique across all of Azure and limited to 24 lowercase letters and digits, so the name is
# a short hash of the app prefix, the subscription, and the region.
remote_state {
  backend = "azurerm"
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = "${local.app_prefix}-tfstate"
    storage_account_name = "tgex${substr(sha1("${local.app_prefix}${local.subscription_id}${local.location}"), 0, 16)}"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/tofu.tfstate"
    location             = local.location

    # Use Entra ID instead of account keys to reach the state, and grant the
    # current identity the blob data role it needs for that.
    use_azuread_auth      = true
    assign_blob_data_role = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repositories to search when you run 'terragrunt catalog'
catalog {
  urls = [
    "https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example"
  ]
}
