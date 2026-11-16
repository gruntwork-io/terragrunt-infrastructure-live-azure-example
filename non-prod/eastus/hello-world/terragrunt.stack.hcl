locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  prefix   = get_env("EX_APP_PREFIX")
  location = local.region_vars.locals.location
}

unit "resource_group" {
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/azure/resource-group"

  path = "resource-group"

  values = {
    name     = "${local.prefix}-hello-dev-rg"
    location = local.location
  }
}

unit "website" {
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//units/azure/storage-account"

  path = "website"

  values = {
    name     = "${local.prefix}hellodev"
    location = local.location
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
    }

    // Adds a static website with one page to the storage account of the catalog unit
    generate "website" {
      path      = "website.tf"
      if_exists = "overwrite_terragrunt"
      contents  = <<-EOF
        resource "azurerm_storage_account_static_website" "site" {
          storage_account_id = azurerm_storage_account.account.id
          index_document     = "index.html"
        }

        resource "azurerm_storage_blob" "index" {
          name                 = "index.html"
          storage_container_id = format("%s/blobServices/default/containers/$web", azurerm_storage_account.account.id)
          type                 = "Block"
          content_type         = "text/html"
          source_content       = "<h1>Hello, world!</h1>"

          depends_on = [azurerm_storage_account_static_website.site]
        }

        output "url" {
          value = azurerm_storage_account.account.primary_web_endpoint
        }
      EOF
    }
  }
}
