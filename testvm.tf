
resource "azurerm_public_ip" "vm_public_ip" {
    name = "${var.vm_name}-ip"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    public_ip_address_allocation = "dynamic"
    domain_name_label = "${var.vm_name}"

    tags {
        environment = "${var.environment_tag}"
    }
}

resource "azurerm_network_interface" "vm_nic" {
    name = "${var.vm_name}-nic"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_id = "${azurerm_network_security_group.vm_security_group.id}"

    ip_configuration {
        name = "${var.vm_name}-ipConfig"
        subnet_id = "${azurerm_subnet.subnet1.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id = "${azurerm_public_ip.vm_public_ip.id}"
    }

    tags {
        environment = "${var.environment_tag}"
    }
}

resource "azurerm_virtual_machine" "virtual_machine" {
    name = "${var.vm_name}"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_interface_ids = ["${azurerm_network_interface.vm_nic.id}"]
    vm_size = "${var.vm_size}"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "${var.vm_name}-osdisk"
        vhd_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}${azurerm_storage_container.container.name}/${var.vm_name}-osdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.vm_name}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        #Include Deploy.PS1 with variables injected as custom_data
        custom_data = "${base64encode("Param($RemoteHostName = \"${null_resource.intermediates.triggers.full_vm_dns_name}\", $ComputerName = \"${var.vm_name}\", $WinRmPort = ${var.vm_winrm_port}) ${file("Deploy.PS1")}")}"
    }

    tags {
        environment = "${var.environment_tag}"
    }

    os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true

        additional_unattend_config {
            pass = "oobeSystem"
            component = "Microsoft-Windows-Shell-Setup"
            setting_name = "AutoLogon"
            content = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
        }
        #Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
        additional_unattend_config {
            pass = "oobeSystem"
            component = "Microsoft-Windows-Shell-Setup"
            setting_name = "FirstLogonCommands"
            content = "${file("FirstLogonCommands.xml")}"
        }
    } 

    provisioner "file" {
        source = "Test.PS1"
        destination = "C:\\Scripts\\Test.PS1"
        connection {
            type = "winrm"
            https = true
            insecure = true
            user = "${var.admin_username}"
            password = "${var.admin_password}"
            host = "${null_resource.intermediates.triggers.full_vm_dns_name}"
            port = "${var.vm_winrm_port}"
        }
    }

    provisioner "remote-exec" {
      inline = [
        "powershell.exe -sta -ExecutionPolicy Unrestricted -file C:\\Scripts\\Test.ps1",
      ]
        connection {
            type = "winrm"
            https = true
            insecure = true
            user = "${var.admin_username}"
            password = "${var.admin_password}"
            host = "${null_resource.intermediates.triggers.full_vm_dns_name}"
            port = "${var.vm_winrm_port}"
        }
    }

}


# Get Server types
# Get-AzureRmVMImagePublisher -Location "North Europe" | ? {$_.PublisherName -match "MicrosoftWindows"}
# Get-AzureRmVMImageOffer -Location "North Europe" -PublisherName "MicrosoftWindowsServer"
# Get-AzureRmVMImageSku -Location "North Europe" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
