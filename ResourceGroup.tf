resource "azurerm_resource_group" "pipelineResources" {
  name     = "pipelineResources"
  location = "North Europe"

  tags {
    environment = "Pipeline"
  }
}