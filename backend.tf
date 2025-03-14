#In this file we will create the function app, the cloud storage dependency and the postgres db


resource "azurerm_storage_account" "cloudstorage129" {
  name                     = "cloudstorage129"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "linuxserviceplan129" {
  name                = "linuxserviceplan129"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_function_app" "functionapp129" {
  name                = "linxufunctionapp129"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  storage_account_name       = azurerm_storage_account.cloudstorage129.name
  storage_account_access_key = azurerm_storage_account.cloudstorage129.primary_access_key
  service_plan_id            = azurerm_service_plan.linuxserviceplan129.id

  virtual_network_subnet_id = azurerm_subnet.api-subnet.id

  site_config {
    always_on = true  # Keeps the function app always running
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"   # Set Python as the worker runtime
    "WEBSITE_RUN_FROM_PACKAGE" = "1"        # Enables deployment from a package
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"  # Ensures dependencies are installed
  }
}

resource "azurerm_private_dns_zone" "postgres-private-dns" {
  name                = "postgresdb129.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres-private-link" {
  name                  = "exampleVnetZone. com"
  private_dns_zone_name = azurerm_private_dns_zone.postgres-private-dns.name
  virtual_network_id    = azurerm_virtual_network.backend_vnet. id
  resource_group_name   = azurerm_resource_group.rg. name
  depends_on            = [azurerm_subnet.sql_private_endpoint_subnet]
}

resource "azurerm_postgresql_flexible_server" "postgresdb" {
  name                          = "postgresdb129"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  version                       = "12"
  delegated_subnet_id           = azurerm_subnet.sql_private_endpoint_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres-private-dns.id
  public_network_access_enabled = false
  administrator_login           = var.sql_admin_user
  administrator_password        = var.sql_admin_password
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P30"

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres-private-link]

