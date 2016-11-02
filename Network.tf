# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "pipelineNetwork" {
  name                = "pipelineNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "North Europe"
  resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
}

resource "azurerm_subnet" "pipelineSubnet1" {
  name                 = "pipelineSubnet1"
  resource_group_name  = "${azurerm_resource_group.pipelineResources.name}"
  virtual_network_name = "${azurerm_virtual_network.pipelineNetwork.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "pipelineSubnet2" {
  name                 = "pipelineSubnet2"
  resource_group_name  = "${azurerm_resource_group.pipelineResources.name}"
  virtual_network_name = "${azurerm_virtual_network.pipelineNetwork.name}"
  address_prefix       = "10.0.2.0/24"
}