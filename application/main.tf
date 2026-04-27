module "poc_rg" {
  source   = "../modules/resource-group"
  name     = "RG1"
  location = "East US"
}

module "app_vnet" {
  source              = "../modules/vnet"
  name                = "app-vnet"
  resource_group_name = module.poc_rg.name
  location            = module.poc_rg.location
  address_space       = ["10.1.0.0/16"]
}

module "hub_vnet" {
  source              = "../modules/vnet"
  name                = "hub-vnet"
  resource_group_name = module.poc_rg.name
  location            = module.poc_rg.location
  address_space       = ["10.0.0.0/16"]
}

module "frontend_subnet" {
  source              = "../modules/subnet"
  name                = "frontend"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.app_vnet.name
  address_prefixes    = ["10.1.0.0/24"]
}

module "backend_subnet" {
  source              = "../modules/subnet"
  name                = "backend"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.app_vnet.name
  address_prefixes    = ["10.1.1.0/24"]
}

module "az_firewall_subnet" {
  source              = "../modules/subnet"
  name                = "AzureFirewallSubnet"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.hub_vnet.name
  address_prefixes    = ["10.0.0.0/26"]
}

resource "azurerm_virtual_network_peering" "app_hub" {
  name                      = "app-vnet-to-hub"
  virtual_network_name      = module.app_vnet.name
  resource_group_name       = module.poc_rg.name
  remote_virtual_network_id = module.hub_vnet.id
}

