
resource "azurerm_network_security_group" "testvm1SecurityGroup" {
    name = "testvm1SecurityGroup"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
}

resource "azurerm_network_security_rule" "rdpRule" {
    name = "rdpRule"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
    network_security_group_name = "${azurerm_network_security_group.testvm1SecurityGroup.name}"
}

