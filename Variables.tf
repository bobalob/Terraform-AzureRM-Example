variable "azure_resource_group_name" {
    description = "Resource Group Name"
    default = "awesomegroup"
}

variable "vm_name" { 
	description = "The Virtual Machine Name"
    default = "davetestvm3"
}

variable "vm_size" { 
	description = "Azure VM Size"
    default = "Basic_A2"
}

variable "vm_winrm_port" {
    description = "WinRM Public Port"
    default = "5986"
}

variable "azure_region" {
    description = "Azure Region for all resources"
    default = "northeurope"
}

variable "azure_region_fullname" {
    description = "Long name for the Azure Region, ie. North Europe"
    default = "North Europe"
}

variable "azure_dns_suffix" {
    description = "Azure DNS suffix for the Public IP"
    default = "cloudapp.azure.com"
}

variable "admin_username" {
    description = "Username for the Administrator account"
    default = "TestAdmin"
}

variable "admin_password" {
    description = "Password for the Administrator account"
    default = "jgjgJGJG!!!!"
}

variable "environment_tag" {
    description = "Tag to apply to the resoucrces"
    default = "Terraform-AzureRM-Example"
}

#Null resource to make the VM intermediate varable - probably not the right way to do this
resource "null_resource" "intermediates" {
    triggers = {
        full_vm_dns_name = "${var.vm_name}.${var.azure_region}.${var.azure_dns_suffix}"
    }
}

output "full_vm_dns_name" {
    value = "${null_resource.intermediates.triggers.full_vm_dns_name}"
}
