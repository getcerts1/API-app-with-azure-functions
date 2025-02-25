resource "azurerm_resource_group" "rg" {
  name     = "cloud-resources"
  location = var.location
}

###  HUB VNET ### - Hosts App Gateway and Bastion
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}




### --- SPOKE VNET --- ###          Hosts Backend Services

resource "azurerm_virtual_network" "backend_vnet" {
  name                = "spoke-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]
}

### HOSTS THE FUNCTION APP ###
resource "azurerm_subnet" "api-subnet" {
  name                 = "API-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.backend_vnet.name
  address_prefixes     = ["10.1.1.0/24"]

  delegation {
    name = "functionapp-delegation"

    #VNET INTEGRATION ALLOWS FUNCTION APP TO COMMUNICATE PRIVATELY WITH POSTGRES VIA THE NIC
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

### HOSTS THE PRIVATE ENDPOINT FOR MY POSTGRES DATABASE ###
resource "azurerm_subnet" "sql_private_endpoint_subnet" {
  name                 = "SQL-private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.backend_vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}
