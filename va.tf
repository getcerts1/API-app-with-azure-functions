variable "location" {
  type = string                     # The type of the variable, in this case a string
  default = "westus"                 # Default value for the variable
  description = "location of resource" # Description of what this variable represents
}

locals {
  backend_address_pool_name      = "app-service-beap"
  frontend_port_name             = "${azurerm_virtual_network.app-vnet. name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.app-vnet. name}-feip"
  http_setting_name              = "${azurerm_virtual_network.app-vnet. name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.app-vnet. name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.app-vnet. name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.app-vnet. name}-rdrcfg"
}