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
  subscription_id   = local.subscription_vars.locals.subscription_id
  subscription_name = local.subscription_vars.locals.subscription_name
  location          = local.region_vars.locals.location

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

# Configure Terragrunt to automatically store tfstate files in an Azure Storage account, one per subscription.
remote_state {
  backend = "azurerm"
  config = {
    subscription_id     = local.subscription_id
    resource_group_name = "${local.app_prefix}-tfstate"

    # The app prefix already makes the name unique, so it needs no hash
    storage_account_name = "${local.app_prefix}${replace(local.subscription_name, "-", "")}tf"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/tofu.tfstate"
    location             = local.location
    enable_soft_delete   = true

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
