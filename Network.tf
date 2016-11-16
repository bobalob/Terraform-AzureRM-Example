# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "network" {
  name                = "${var.azure_resource_group_name}-Network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.azure_resource_group_name}-Subnet1"
  resource_group_name  = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "10.0.1.0/24"
}
