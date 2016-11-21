resource "azurerm_availability_set" "availability_set" {
  name                         = "${var.vm_name_prefix}-avset"
  location                     = "${var.azure_region_fullname}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"

  tags {
    environment = "${var.environment_tag}"
  }
}