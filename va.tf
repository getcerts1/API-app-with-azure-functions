variable "location" {
  type        = string
  default     = "westus"
  description = "location of resource"
}
variable "storage_string" {
  type    = string
  default = "storage_subnet"
}

variable "database_string" {
  type    = string
  default = "database_subnet"
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  description = "password for sql db admin"

}
locals {
  backend_address_pool_name      = "app-service-beap"
  frontend_port_name             = "${azurerm_virtual_network.app_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.app_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.app_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.app_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.app_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.app_vnet.name}-rdrcfg"
}