# Terraform-AzureRM-Example

Quick Instruction:

Download and install Terraform
https://www.terraform.io/downloads.html

Edit the TerraformCredentials.ps1 and enter API keys

Load Powershell

"dot source" the credentials to load them into environment variables

      . .\TerraformCredentials.ps1

Test the configuration

      terraform plan

Build the resources

      terraform apply

Delete the resources

      terraform destroy

Information

http://superautomation.blogspot.co.uk/2016/11/terraform-with-azure-resource-manager.html
http://superautomation.blogspot.co.uk/2016/11/configuring-terraform-to-use-winrm-over.html
http://superautomation.blogspot.co.uk/2016/11/azure-resource-manager-load-balancer.html
