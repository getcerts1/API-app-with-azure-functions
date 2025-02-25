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