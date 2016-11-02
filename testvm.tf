
resource "azurerm_public_ip" "testPublicIp" {
    name = "testPublicIp"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Pipeline environment"
    }
}

resource "azurerm_network_interface" "testnic" {
    name = "testvm1nic"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"

    ip_configuration {
        name = "testconfiguration1"
        subnet_id = "${azurerm_subnet.pipelineSubnet1.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.testPublicIp.id}"
        
    }

}

resource "azurerm_virtual_machine" "testvm1" {
    name = "testvm1"
    location = "North Europe"
    resource_group_name = "${azurerm_resource_group.pipelineResources.name}"
    network_interface_ids = ["${azurerm_network_interface.testnic.id}"]
    vm_size = "Basic_A1"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "testvm1osdisk1"
        vhd_uri = "${azurerm_storage_account.testStorageAccount.primary_blob_endpoint}${azurerm_storage_container.testStorageContainerVhds.name}/testvm1osdisk1.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "testvm1"
        admin_username = "TestAdmin"
        admin_password = "c8920f35ny84950n7"
    }

    tags {
        environment = "Pipeline environment"
    }
}


# Get Server types
# Get-AzureRmVMImagePublisher -Location "North Europe" | ? {$_.PublisherName -match "MicrosoftWindows"}
# Get-AzureRmVMImageOffer -Location "North Europe" -PublisherName "MicrosoftWindowsServer"
# Get-AzureRmVMImageSku -Location "North Europe" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
