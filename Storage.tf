
resource "azurerm_storage_account" "storage_account" {
    name = "${var.azure_resource_group_name}storages"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    location = "${var.azure_region_fullname}"
    account_type = "Standard_LRS"

    tags {
        environment = "${var.environment_tag}"
    }
}

resource "azurerm_storage_container" "container" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    storage_account_name = "${azurerm_storage_account.storage_account.name}"
    container_access_type = "private"
}
