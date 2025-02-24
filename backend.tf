###  VNet Integration for Function App  ###

resource "azurerm_storage_account" "cloud_api_storage" {
  name                     = "linuxfunctionappsa129"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "api_linux_service_plan" {
  name                = "my-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "my_linux_function_app" {
  name                = "my-function-app129"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.cloud_api_storage.name
  storage_account_access_key = azurerm_storage_account.cloud_api_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.api_linux_service_plan.id
  virtual_network_subnet_id = azurerm_subnet.api-subnet.id

  site_config {
    vnet_route_all_enabled = true # Ensure all traffic follows the VNet routes
  }


}

# ✅ Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "storage-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id          = azurerm_subnet.storage_private_endpoint_subnet.id

  private_service_connection {
    name                           = "storage-connection"
    private_connection_resource_id = azurerm_storage_account.cloud_api_storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

### Private Endpoint for PostgreSQL ###
resource "azurerm_postgresql_server" "postgres_db" {
  name                = "my-postgres-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_name            = "B_Gen5_2"
  storage_mb          = 5120
  version             = "11"
  administrator_login = "adminuser"
  administrator_login_password = var.sql_admin_password
  ssl_enforcement_enabled = false
}

resource "azurerm_private_endpoint" "postgres_private_endpoint" {
  name                = "postgres-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id          = azurerm_subnet.sql_private_endpoint_subnet.id

  private_service_connection {
    name                           = "postgres-connection"
    private_connection_resource_id = azurerm_postgresql_server.postgres_db.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

### Private DNS for Storage Account ###
resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_link" {
  name                  = "storage-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_a_record" "storage_dns_record" {
  name                = "storage"
  zone_name           = azurerm_private_dns_zone.storage_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_private_endpoint.private_service_connection[0].private_ip_address]
}

# ✅ Private DNS for PostgreSQL
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                  = "postgres-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_a_record" "postgres_dns_record" {
  name                = "postgres"
  zone_name           = azurerm_private_dns_zone.postgres_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.postgres_private_endpoint.private_service_connection[0].private_ip_address]
}
