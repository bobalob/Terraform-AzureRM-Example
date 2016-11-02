
resource "azurerm_storage_account" "testStorageAccount" {
    name = "teststorageaccount99"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
    location = "North Europe"
    account_type = "Standard_LRS"

    tags {
        environment = "staging"
    }
}

resource "azurerm_storage_container" "testStorageContainerVhds" {
    name = "vhds"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
    storage_account_name = "${azurerm_storage_account.testStorageAccount.name}"
    container_access_type = "private"
}
