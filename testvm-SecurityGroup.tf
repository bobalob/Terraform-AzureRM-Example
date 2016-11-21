
resource "azurerm_network_security_group" "vm_security_group" {
    name = "${var.vm_name_prefix}-sg"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"

    tags {
        environment = "${var.environment_tag}"
    }
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
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_name = "${azurerm_network_security_group.vm_security_group.name}"
}

resource "azurerm_network_security_rule" "winrmRule" {
    name = "winrmRule"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "${var.vm_winrm_port}"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_name = "${azurerm_network_security_group.vm_security_group.name}"
}

resource "azurerm_network_security_rule" "httpRule" {
    name = "HTTP"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_name = "${azurerm_network_security_group.vm_security_group.name}"
}

resource "azurerm_network_security_rule" "httpsRule" {
    name = "HTTPS"
    priority = 130
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_name = "${azurerm_network_security_group.vm_security_group.name}"
}

