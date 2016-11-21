# TODO: Add the availability set and the VMs to the load balanacer

# VIP address
resource "azurerm_public_ip" "load_balancer_public_ip" {
  name                         = "${var.vm_name_prefix}-ip"
  location                     = "${var.azure_region_fullname}"
  resource_group_name          = "${azurerm_resource_group.resource_group.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label = "${azurerm_resource_group.resource_group.name}"
}

# Front End Load Balancer
resource "azurerm_lb" "load_balancer" {
  name                = "${var.vm_name_prefix}-lb"
  location            = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  frontend_ip_configuration {
    name                 = "${var.vm_name_prefix}-ipconfig"
    public_ip_address_id = "${azurerm_public_ip.load_balancer_public_ip.id}"
  }
}

# Back End Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  location            = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "${var.vm_name_prefix}-backend_address_pool"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "load_balancer_http_rule" {
  location                       = "${var.azure_region_fullname}"
  resource_group_name            = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "HTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.load_balancer_probe.id}"
  depends_on                     = ["azurerm_lb_probe.load_balancer_probe"]
}

resource "azurerm_lb_rule" "load_balancer_https_rule" {
  location                       = "${var.azure_region_fullname}"
  resource_group_name            = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "HTTPSRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.vm_name_prefix}-ipconfig"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  probe_id                       = "${azurerm_lb_probe.load_balancer_probe.id}"
  depends_on                     = ["azurerm_lb_probe.load_balancer_probe"]
}

#LB Probe - Checks to see which VMs are healthy and available
resource "azurerm_lb_probe" "load_balancer_probe" {
  location            = "${var.azure_region_fullname}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "HTTP"
  port                = 80
}

#TODO: Dynamic NAT rules for each VM for WinRM