terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "app-rg-1"
  location = var.location
}

resource "azurerm_virtual_network" "hub_vnet" {
  address_space = [10.0.0.0/16]
  location            = var.location
  name                = "hub-vnet"
  resource_group_name = azurerm_resource_group.rg.name

    subnet "azurerm_subnet" "bastion_subnet" {
    address_prefixes = [10.0.0.0/24]
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
  }

    subnet "azurerm_subnet" "firewall_subnet" {
    address_prefixes = [10.0.1.0/26]
    name                 = "AzureFirewallSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.hub_vnet.name
    }
}

resource "azurerm_public_ip" "Bastion-pip" {
  name                = "Bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
  location            = var.location
  name                = "hub-bastion"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = lookup(azurerm_virtual_network.hub_vnet.subnet[0],"id")
    public_ip_address_id = azurerm_public_ip.Bastion-pip.id
  }
}

resource "azurerm_public_ip" "Firewall-pip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "Firewall-pip"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_firewall" "utilities_firewall" {
  location            = var.location
  name                = "utilites_firewall"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
}


resource "azurerm_virtual_network" "app-vnet" {
  address_space = [10.1.0.0/16]
  location            = var.location
  name                = app-vnet
  resource_group_name = azurerm_resource_group.rg.name

    subnet "application_gateway_subnet" {
      address_prefixes = [10.1.0.0/24]
      name = "ApplicationGatewaySubnet"
    }

    subnet "web-tier" {
      address_prefixes = [10.1.1.0/24]
      name = "web-tier-subnet"
    }

    subnet "database_subnet" {
    address_prefixes = [10.1.2.0/24]
    name = "database_subnet"
  }
}

resource "azurerm_app_service_plan" "utilities_app_service_plan" {
  name                = "utilities_app_service_plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}



resource "azurerm_app_service" "app-service_1" {
  app_service_plan_id = lookup(azurerm_app_service_plan,"id")
  location            = var.location
  name                = "utilities_app_service"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_public_ip" "app_gateway_public_ip" {
  allocation_method   = "Static"
  location            = var.location
  name                = "app_gateway_public_ip"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_application_gateway" "app-gateway" {
  location            = var.location
  name                = "utilites-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = lookup(azurerm_virtual_network.app-vnet.subnet[0], "id")
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [azurerm_app_service.app-service_1.default_site_hostname]
  }

  backend_http_settings {
    name                  = local. http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/ path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local. listener_name
    frontend_ip_configuration_name = local. frontend_ip_configuration_name
    frontend_port_name             = local. frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}


