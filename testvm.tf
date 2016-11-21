
#resource "azurerm_public_ip" "vm_public_ip" {
#    name = "${var.vm_name_prefix}-${count.index}-ip"
#    location = "${var.azure_region_fullname}"
#    resource_group_name = "${azurerm_resource_group.resource_group.name}"
#    public_ip_address_allocation = "dynamic"
#    domain_name_label = "${var.vm_name_prefix}-${count.index}"
#    count = "${var.vm_count}"
#
#    tags {
#        environment = "${var.environment_tag}"
#    }
#}

resource "azurerm_lb_nat_rule" "winrm_nat" {
  location = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id = "${azurerm_lb.load_balancer.id}"
  name = "WinRM-HTTPS-vm-${count.index}"
  protocol = "Tcp"
  frontend_port = "${count.index + 10000}"
  backend_port = "${var.vm_winrm_port}"
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
  count = "${var.vm_count}"
}

resource "azurerm_lb_nat_rule" "rdp_nat" {
  location = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id = "${azurerm_lb.load_balancer.id}"
  name = "RDP-vm-${count.index}"
  protocol = "Tcp"
  frontend_port = "${count.index + 11000}"
  backend_port = "3389"
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
  count = "${var.vm_count}"
}


resource "azurerm_network_interface" "vm_nic" {
    name = "${var.vm_name_prefix}-${count.index}-nic"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_security_group_id = "${azurerm_network_security_group.vm_security_group.id}"
    count = "${var.vm_count}"

    ip_configuration {
        name = "${var.vm_name_prefix}-${count.index}-ipConfig"
        subnet_id = "${azurerm_subnet.subnet1.id}"
        private_ip_address_allocation = "dynamic"
        #public_ip_address_id = "${element(azurerm_public_ip.vm_public_ip.*.id, count.index)}"
        load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
        load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_rule.winrm_nat.*.id, count.index)}"]
        #, "${element(azurerm_lb_nat_rule.rdp_nat.*.id, count.index)}"
    }

    tags {
        environment = "${var.environment_tag}"
    }
}

resource "azurerm_virtual_machine" "virtual_machine" {
    name = "${var.vm_name_prefix}-${count.index}"
    location = "${var.azure_region_fullname}"
    resource_group_name = "${azurerm_resource_group.resource_group.name}"
    network_interface_ids = ["${element(azurerm_network_interface.vm_nic.*.id, count.index)}"]
    vm_size = "${var.vm_size}"
    count = "${var.vm_count}"
    availability_set_id = "${azurerm_availability_set.availability_set.id}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name = "${var.vm_name_prefix}-${count.index}-osdisk"
        vhd_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}${azurerm_storage_container.container.name}/${var.vm_name_prefix}-${count.index}-osdisk.vhd"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = "${var.vm_name_prefix}-${count.index}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
        #Include Deploy.PS1 with variables injected as custom_data
        custom_data = "${base64encode("Param($RemoteHostName = \"${var.vm_name_prefix}-${count.index}.${var.azure_region}.${var.azure_dns_suffix}\", $ComputerName = \"${var.vm_name_prefix}-${count.index}\", $WinRmPort = ${var.vm_winrm_port}) ${file("Deploy.PS1")}")}"
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
        source = "WebserverDsc.PS1"
        destination = "C:\\Scripts\\WebserverDsc.PS1"
        connection {
            type = "winrm"
            https = true
            insecure = true
            user = "${var.admin_username}"
            password = "${var.admin_password}"
            host = "${azurerm_resource_group.resource_group.name}.${var.azure_region}.${var.azure_dns_suffix}"
            port = "${count.index + 10000}"
        }
    }

    provisioner "file" {
        content = "${var.vm_name_prefix}-${count.index}"
        destination = "C:\\inetpub\\wwwroot\\default.htm"
        connection {
            type = "winrm"
            https = true
            insecure = true
            user = "${var.admin_username}"
            password = "${var.admin_password}"
            host = "${azurerm_resource_group.resource_group.name}.${var.azure_region}.${var.azure_dns_suffix}"
            port = "${count.index + 10000}"
        }
    }

    provisioner "remote-exec" {
      inline = [
        "powershell.exe -sta -ExecutionPolicy Unrestricted -file C:\\Scripts\\WebserverDsc.ps1",
      ]
        connection {
            type = "winrm"
            timeout = "20m"
            https = true
            insecure = true
            user = "${var.admin_username}"
            password = "${var.admin_password}"
            host = "${azurerm_resource_group.resource_group.name}.${var.azure_region}.${var.azure_dns_suffix}"
            port = "${count.index + 10000}"
        }
    }

}


# Get Server types
# Get-AzureRmVMImagePublisher -Location "North Europe" | ? {$_.PublisherName -match "MicrosoftWindows"}
# Get-AzureRmVMImageOffer -Location "North Europe" -PublisherName "MicrosoftWindowsServer"
# Get-AzureRmVMImageSku -Location "North Europe" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
# Get-AzureRmVMImage -Location "North Europe" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Nano-Server"