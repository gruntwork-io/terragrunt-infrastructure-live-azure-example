[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_terragrunt-infra-live-azure-example)

# Example infrastructure-live for Terragrunt on Azure (with Stacks)

This repository, along with the [terragrunt-infrastructure-catalog-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example),
offers a best practice system for organizing your Infrastructure as Code (IaC) on Azure so that you can maintain your
IaC at any scale with confidence using an `infrastructure-live` repository.

It follows the same patterns as the [terragrunt-infrastructure-live-stacks-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example), which does the same for AWS.

If you have not already done so, you are encouraged to read the [Terragrunt Getting Started Guide](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/) to get familiar with the terminology and concepts used in this repository before proceeding.

## What is an `infrastructure-live` repository?

An `infrastructure-live` repository is a Gruntwork best practice for managing your "live" infrastructure. That is, the
infrastructure that is actually provisioned, as opposed to infrastructure patterns that *can* be provisioned.

## Key Features & Benefits

This repository provides a practical blueprint for managing Azure infrastructure with Terragrunt, demonstrating:

* **Modern Terragrunt Workflow:** Leverages Terragrunt Stacks for clear dependency management and streamlined multi-component deployments.
* **Scalable `infrastructure-live` Structure:** Organizes infrastructure logically by subscription and region, providing a proven foundation adaptable to growing complexity.
* **Best-Practice Separation:** Clearly separates environment-specific "live" configurations (this repo) from reusable infrastructure patterns (via an `infrastructure-catalog`).
* **DRY Configuration:** Reduces code duplication using hierarchical configuration files (`root.hcl`, `subscription.hcl`, `region.hcl`).
* **Concrete End-to-End Example:** Deploys the foundation for an application (resource group, storage, container registry, and a managed identity with only the access it needs) across distinct production and non-production environments.
* **Secure State by Default:** Stores state in Azure Storage, reached with Entra ID instead of storage account keys.
* **Reproducible Tooling:** Includes `mise` configuration for easy installation of pinned versions of Terragrunt and OpenTofu/Terraform.

## Getting Started

To use this repository, you'll want to fork this repository into your own Git organization.

The steps for doing this are the following:

1. Create a new Git repository in your organization (e.g. [GitHub](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository), [GitLab](https://docs.gitlab.com/user/project/repository/)).

2. Create a bare clone of this repository somewhere on your local machine.

   ```bash
   git clone --bare https://github.com/gruntwork-io/terragrunt-infrastructure-live-azure-example.git
   ```

3. Push the bare clone to your new Git repository.

   ```bash
   cd terragrunt-infrastructure-live-azure-example.git
   git push --mirror <YOUR_GIT_REPO_URL> # e.g. git push --mirror git@github.com:acme/terragrunt-infrastructure-live-azure-example.git
   ```

4. Remove the local clone of the repository.

   ```bash
   cd ..
   rm -rf terragrunt-infrastructure-live-azure-example.git
   ```

5. (Optional) Delete the contents of this usage documentation from your fork of this repository.

## Prerequisites

To use this repository, you'll want to make sure you have the following installed:

- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

To simplify the process of installing Terragrunt and OpenTofu, you can install [mise](https://mise.jdx.dev/), then run the following to concurrently install them, pinned to the versions they were tested with (as tracked in the [mise.toml](./mise.toml) file):

```bash
mise install
```

You'll also need the **Owner** or **User Access Administrator** role on the subscriptions you deploy to, because both the state backend and the stacks create role assignments. **Contributor** can't do that. See [Required Azure permissions](https://docs.terragrunt.com/features/units/authentication/azure/#required-permissions).

## Repository Contents

> [!NOTE]
> This code is solely for demonstration purposes. This is not production-ready code, so use at your own risk. If you are interested in battle-tested, production-ready Terragrunt and OpenTofu/Terraform code, continuously updated and maintained by a team of subject matter experts, consider purchasing a subscription to the [Gruntwork IaC Library](https://www.gruntwork.io/platform/iac-library).

This repository contains the following:

- `root.hcl`: The root Terragrunt configuration inherited by all other Terragrunt units in this repository. This file contains code that reads the `subscription.hcl` and `region.hcl` files in every unit, and leverages them for provider and backend configurations.

- `non-prod`/`prod` directories: Each of these directories are a representation of an Azure subscription, and all the infrastructure that's provisioned for a subscription can be found in the respective directory.

- `subscription.hcl` files: In each subscription directory, there is a `subscription.hcl` file that defines the common configurations for that subscription.

- `region.hcl` files: In each region directory (e.g. `eastus`), there is a `region.hcl` file that defines the common configurations for that region.

- `terragrunt.stack.hcl` files: These files define a stack of Terragrunt units.

  Both the `terragrunt.stack.hcl` files in this repository use the `app-foundation` stack, which provisions what an application needs before it can run, including:

  - Resource Group
  - Storage Account, with a private `data` blob container and an `items` table
  - Container Registry
  - Managed Identity, with `AcrPull` on the registry, plus `Storage Blob Data Reader` and `Storage Table Data Contributor` on the storage account
  - Alerts on the storage account's availability and latency (`prod` only)

  This example doesn't deploy application code, so it ends with the resources above and their outputs.

  The configurations for these resources aren't defined in this repository, but are instead defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

  This is a recommended, Gruntwork best practice, as it allows infrastructure teams to iterate on infrastructure patterns as versioned, immutable artifacts, and then reference pinned versions of these patterns in their "live" infrastructure-live repositories.

## Best practices for an `infrastructure-live` repository

The following conventions are some best practices for an `infrastructure-live` repository, as defined by Gruntwork:

- Primarily use [Terragrunt](https://terragrunt.gruntwork.io/) configurations to define your IaC.
- Avoid using OpenTofu/Terraform directly in `infrastructure-live` repositories. Instead, prefer to author them in an `infrastructure-catalog` repository (see [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example)).
- Follow [Trunk-Based Development](https://trunkbaseddevelopment.com/). The source of truth for your infrastructure is the code in the `main` branch (or whatever you configure the default branch to be).
- Avoid using [OpenTofu/Terraform Workspaces](https://opentofu.org/docs/language/state/workspaces/). Instead, use [Terragrunt units](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#unit) to isolate state.
- Use [Stacks](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#stack) to organize your infrastructure into logical collections of units.

## How to provision the infrastructure in this repository

### Setup

Before you start provisioning the infrastructure in this repository, you'll want to do the following:

1. Log in with the Azure CLI, and select the subscription to deploy into.

   ```bash
   az login
   az account set --subscription "<YOUR_SUBSCRIPTION>"
   ```

   Terragrunt and the OpenTofu Azure provider use the Azure CLI credentials. See [Azure authentication](https://docs.terragrunt.com/features/units/authentication/azure/) for other options, such as a service principal or a managed identity in CI.

2. Set the `EX_NON_PROD_SUBSCRIPTION_ID` and `EX_PROD_SUBSCRIPTION_ID` environment variables to the Azure subscription IDs you want to use for non-production and production workloads, respectively.

   ```bash
   export EX_NON_PROD_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
   export EX_PROD_SUBSCRIPTION_ID="11111111-1111-1111-1111-111111111111"
   ```

   Alternatively, you can replace the `get_env(...)` calls in [`non-prod/subscription.hcl`](/non-prod/subscription.hcl) and [`prod/subscription.hcl`](/prod/subscription.hcl) with hardcoded subscription ID strings.

   > [!TIP]
   > If you want everything deployed in a single Azure subscription, you can set both environment variables to the same value (or use the same hardcoded string in both files). For example, to use the subscription you selected above:
   >
   > ```bash
   > export EX_NON_PROD_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
   > export EX_PROD_SUBSCRIPTION_ID="$EX_NON_PROD_SUBSCRIPTION_ID"
   > ```

3. Set the `EX_APP_PREFIX` environment variable to something unique to you, using at most 15 lowercase letters and digits.

   ```bash
   export EX_APP_PREFIX="acme"
   ```

   It's required, because storage account and container registry names are unique across all of Azure, and they can't contain dashes. The stacks name their resources with it (e.g. `acmeappdev-rg`, `acmeappdevsa`, `acmeappdevacr`), and the state backend uses it too.

4. Review the `remote_state` block in the `root.hcl` file. It stores state in an Azure Storage account in each subscription and region.

   ```hcl
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
   ```

   Storage account names are unique across all of Azure and limited to 24 lowercase letters and digits, so the name is `tgex` followed by a short hash of the app prefix, the subscription, and the region. You can change the `tgex` prefix and the `-tfstate` resource group name if you like. See the [azurerm backend docs](https://docs.terragrunt.com/features/units/state-backend/azurerm/) for all the options.

   With `use_azuread_auth`, Terragrunt and OpenTofu reach the state with your Entra ID identity instead of storage account keys, and `assign_blob_data_role` grants that identity the `Storage Blob Data Contributor` role on the storage account if it doesn't have it yet.

   If you deploy everything to a single Azure subscription, both `non-prod` and `prod` store state in the same storage account, under different keys.

### Provisioning a single stack

1. Navigate to the directory of the stack you want to provision.
   e.g.

   ```bash
   cd non-prod/eastus/app-foundation
   ```

2. Run the following to generate the relevant units for the stack, and run a plan against them.

   ```bash
   terragrunt run --all --non-interactive --backend-bootstrap plan
   ```

   > [!TIP]
   >
   > The `--backend-bootstrap` flag there allows Terragrunt to automatically create relevant backend resources for you before running OpenTofu. Here, that's the resource group, the storage account, and the `tfstate` container.
   >
   > You don't need to use the flag if you are using backend resources that already exist, or don't want Terragrunt to create them for you.
   >
   > If the first run fails while creating the storage account, or with a `403` while reading the container, run it again. Bootstrap picks up what already exists, and Azure can take a few minutes to apply a new role assignment.

3. If the plan looks good, run the following to apply the changes.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

### Provisioning all stacks

If you want to provision all the stacks in this repository, you can do the same at the root of the repository.

1. Navigate back up to the root of the repository.

   ```bash
   cd ../../..
   ```

2. Plan all units.

   ```bash
   terragrunt run --all --non-interactive --backend-bootstrap plan
   ```

3. Apply all units.

   ```bash
   terragrunt run --all --non-interactive apply
   ```

## Interacting with the provisioned infrastructure

If you'd like to interact with the infrastructure that was just provisioned, you can do the following:

1. Get the output values for the stack that you just provisioned.

   ```bash
   $ cd non-prod/eastus/app-foundation
   $ terragrunt stack output
   app = {
     container_registry = {
       id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.ContainerRegistry/registries/acmeappdevacr"
       login_server = "acmeappdevacr.azurecr.io"
       name         = "acmeappdevacr"
     }
     identity = {
       client_id    = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
       id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/acmeappdev-identity"
       name         = "acmeappdev-identity"
       principal_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
       role_assignment_ids = {
         acr_pull          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.ContainerRegistry/registries/acmeappdevacr/providers/Microsoft.Authorization/roleAssignments/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
         blob_reader       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.Storage/storageAccounts/acmeappdevsa/providers/Microsoft.Authorization/roleAssignments/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
         table_contributor = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.Storage/storageAccounts/acmeappdevsa/providers/Microsoft.Authorization/roleAssignments/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
       }
     }
     resource_group = {
       id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg"
       location = "eastus"
       name     = "acmeappdev-rg"
     }
     storage_account = {
       id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.Storage/storageAccounts/acmeappdevsa"
       name                  = "acmeappdevsa"
       primary_blob_endpoint = "https://acmeappdevsa.blob.core.windows.net/"
     }
     table = {
       id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/acmeappdev-rg/providers/Microsoft.Storage/storageAccounts/acmeappdevsa/tableServices/default/tables/items"
       name = "items"
     }
   }
   ```

   Note that all the units in the stack display their outputs here. Outputs are organized by stack, then unit, then output name.

2. Use the output values to interact with the infrastructure.

   ```bash
   $ PRINCIPAL_ID="$(terragrunt stack output --raw app.identity.principal_id)"
   $ az role assignment list --all --assignee "$PRINCIPAL_ID" --query "[].roleDefinitionName" --output tsv
   Storage Blob Data Reader
   AcrPull
   Storage Table Data Contributor
   ```

   This lists the roles the stack gave the managed identity. An application that runs as this identity can pull images from the registry, read blobs, and read and write table entities, and nothing else.

   Outputs can be indexed by output key. In this case, the `identity` unit of the `app` stack has an output key of `principal_id`, so we can access it directly with `app.identity.principal_id`. When outputs are nested into stacks, you can access them by chaining the stack name, unit name, and output key.

## Cleaning up

1. Destroy the infrastructure, from a stack directory or from the root of the repository.

   ```bash
   terragrunt run --all --non-interactive destroy
   ```

2. Delete the resource group that holds the state. Only do this once nothing else stores state there.

   ```bash
   az group delete --name "${EX_APP_PREFIX}-tfstate"
   ```

## Browsing the infrastructure catalog

The `catalog` block at the end of [`root.hcl`](./root.hcl) lists repositories of reusable infrastructure that you can build on in this repository:

```hcl
catalog {
  urls = [
    "https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example"
  ]
}
```

To browse them, run the following from the root of the repository:

```bash
terragrunt catalog
```

Terragrunt reads the `catalog` block from `root.hcl`, clones each repository into a temporary directory, and opens a terminal UI listing the components it found: OpenTofu/Terraform modules, Boilerplate templates and Terragrunt units + stacks. You can also run it from any directory below the root, since Terragrunt searches parent directories for `root.hcl`.

In the terminal UI:

- Press `Tab` and `Shift+Tab` to switch between tabs that show all components or one kind at a time.
- Press `/` and start typing to filter the list.
- Use the arrow keys to move through the list.
- Press `Enter` to read the README of the selected component.
- Press `s` to scaffold the selected component.
- Press `q` to quit.

Scaffolding writes to the directory you launched the catalog from, so create the directory for the new component and run the catalog from there. Units and stacks are copied as they are, and templates are rendered with Boilerplate. A module gets a new unit with a `terragrunt.hcl` file, which by default includes a root file named `root.hcl`.

The Azure components in the catalog are under `modules/azure`, `units/azure` and `stacks/azure`.

To browse a different repository, pass its URL to the command (e.g. `terragrunt catalog https://github.com/acme/infrastructure-catalog`), or add it to the `urls` list in `root.hcl` to share it with everyone working in this repository. For more, see the [Catalog docs](https://docs.terragrunt.com/features/catalog).

## How is the code in this repository organized?

The IaC code in this repository is organized into a hierarchy of Terragrunt stacks, representing the blast radius of the infrastructure being managed in the context of Azure infrastructure management.

The hierarchy is as follows:

```tree
subscription
 `-- region
      `-- resources
```

Where:

- `subscription` is the Azure subscription being managed (e.g. `non-prod`, `prod`, `mgmt`).
- `region` is the Azure region being managed (e.g. `eastus`).
- `resources` are the resources being managed (e.g. `app-foundation`).

This structure is geared towards exclusive management of infrastructure in Azure, but can be adapted to other cloud providers, etc. by adjusting the hierarchy according to the patterns of the platform.

The top-level `subscription` and `region` directories are there to give clear context for users that are familiar with Azure infrastructure management. Authentication and configuration of the OpenTofu Azure provider is specific to the subscription, and every Azure resource lives in a region, so it's also useful to have these directories to provide a straight-forward way to configure the provider, the state backend, and the location of the resources.

Azure also groups resources into resource groups. In this repository, each stack creates its own resource group, so the directory structure decides what is managed together. The only shared resource group is the one that holds the state, which Terragrunt creates for you.

Many teams like to organize their environments into individual Azure subscriptions, and this structure makes it easy to do that. If you are part of a team that manages multiple environments in a single Azure subscription, you can simply add a new level of hierarchy under the `region` directory, like this:

```tree
subscription
 `-- region
      `-- environment
           `-- resources
```

There's also an established convention to leverage a special `_global` directory to manage resources that are available across all regions, environments, etc. Structuring your IaC like that would look like this:

```tree
subscription
 |-- _global
 |    `-- resources
 `-- region
      |-- _global
      |    `-- resources
      `-- environment
           `-- resources
```

Where:

- **Subscription-level `_global`**: Contains resources that are available across all regions in the subscription, such as Azure Policy assignments, subscription role assignments, budgets, and DNS zones.
- **Region-level `_global`**: Contains resources that are available across all environments in a region, such as virtual networks, Log Analytics workspaces, and shared container registries.

The `resources` directory can be arbitrarily deep, and can be used to organize resources under management in a way that makes sense for the team managing the infrastructure. In this repository it's fairly shallow for the sake of simplicity, with the units constituting the stack defined in the [terragrunt-infrastructure-catalog-example](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) repository.

## Where to store configuration

### `root.hcl`

The contents of the `root.hcl` file is configuration that is common to all units the repository. It's idiomatic Terragrunt code to always include this root file in every unit. There's very frequently some boilerplate configuration like defining the OpenTofu provider, setting state backend configurations, etc. that have to be repeated in every unit, so it's nice to have it defined once in the root file, and included in every unit.

Avoid overloading this file with too much configuration, as it might not be the right level of abstraction for the configuration you need. Instead, prefer to use `terragrunt.stack.hcl` files to define configurations in `values` attributes, and pass down the values to the stacks and units that need them.

### `terragrunt.stack.hcl`

The `terragrunt.stack.hcl` file is used to define configurations for a stack of Terragrunt units. Any time you have multiple `terragrunt.hcl` files that need to be run together as part of your infrastructure deployment, you can define a `terragrunt.stack.hcl` file instead to encapsulate those configurations as a single entity that can be reliably reproduced across subscriptions, regions, environments, etc.

Using the `values` attribute of [stack](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#stack) and [unit](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#unit) configuration blocks allows you to pass down configuration to units with granular control.

For example, consider the [prod/eastus/app-foundation/terragrunt.stack.hcl](prod/eastus/app-foundation/terragrunt.stack.hcl) file:

```hcl
locals {
  // Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  // Also names the storage account and container registry, which are unique across all of Azure.
  name = "${get_env("EX_APP_PREFIX")}appprod"
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

    // Alert on the storage account's availability and latency, in prod only
    enable_alerts = true
  }
}
```

Here, you can see that the `values` attribute is setting exactly the values that are unique to the `app-foundation` stack in the context of `prod`: the name of its resources, the location it reads from `region.hcl`, and `enable_alerts`, which turns on the `alerts` unit that `non-prod` leaves out.

A `stack` block pulls in a whole stack from the catalog, so this file stays short. If you need to change how a single unit is configured, you can instead list `unit` blocks in the `terragrunt.stack.hcl` file, the way the [terragrunt-infrastructure-live-stacks-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example) repository does.

### Declaring dependencies between units

The units in the `app-foundation` stack depend on each other. For example, the `storage_account` unit needs the name of the resource group created by the `resource_group` unit, and the `identity` unit needs the IDs of the storage account and container registry to scope its role assignments. The catalog's stack file declares these dependencies directly using an [`autoinclude`](https://terragrunt.gruntwork.io/docs/reference/hcl/blocks/#autoinclude) block:

```hcl
unit "storage_account" {
  source                 = "../../..//units/azure/storage-account"
  update_source_with_cas = true

  path = "storage-account"

  values = {
    name            = "${local.name}sa"
    location        = local.location
    container_names = try(values.container_names, ["data"])
    tags            = local.tags
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
  }
}
```

- `config_path = unit.resource_group.path` resolves to the generated directory of the `resource_group` unit, so you never compute relative paths like `../resource-group` by hand. If you rename or relocate a unit, the reference follows it automatically.
- `mock_outputs` provide placeholder values so that a `plan` succeeds before the dependencies have been applied.

When you run `terragrunt stack generate`, Terragrunt writes each declared dependency into a `terragrunt.autoinclude.hcl` file next to the generated unit, then merges it into that unit whenever the unit is run. As a result, the catalog units stay free of any knowledge about where their dependencies live: the `storage-account` unit simply consumes `resource_group_name`, and the stack decides which `resource_group` unit satisfies that dependency.

This is the [stacks dependencies](https://terragrunt.gruntwork.io/docs/features/stacks/explicit/#declaring-dependencies-between-units) feature, which is enabled by default in Terragrunt `v1.1.0` and later.

## What to do with `.terraform.lock.hcl` files

When you run `terragrunt` commands you may find that `.terraform.lock.hcl` files are created in your working directories.

These files are intentionally not committed to this example repository, but definitely should be in your own repositories!

They help make sure that your IaC results in reproducible infrastructure. For more on this, read [Lock File Handling docs](https://docs.terragrunt.com/features/units/lock-files/).

## How to get help

If you need help troubleshooting usage of this repository, or Terragrunt in general, check out the [Support docs](https://terragrunt.gruntwork.io/docs/community/support/).
