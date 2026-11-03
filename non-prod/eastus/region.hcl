# Set common variables for the region. This is automatically pulled in by the root.hcl configuration to configure the
# remote state storage account, and by the stacks in this region to set their location.
locals {
  location = "eastus"
}
