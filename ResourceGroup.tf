resource "azurerm_resource_group" "resource_group" {
  name     = "${var.azure_resource_group_name}"
  location = "${var.azure_region_fullname}"

  tags {
    environment = "${var.environment_tag}"
  }
}