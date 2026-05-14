module "poc_rg" {
  source   = "../modules/resource-group"
  name     = "az104-rg5"
  location = "East US"
}

module "core_vnet" {
  source              = "../modules/vnet"
  name                = "CoreServicesVnet"
  resource_group_name = module.poc_rg.name
  location            = module.poc_rg.location
  address_space       = ["10.0.0.0/16"]
}

module "mfg_vnet" {
  source              = "../modules/vnet"
  name                = "ManufacturingVnet"
  resource_group_name = module.poc_rg.name
  location            = module.poc_rg.location
  address_space       = ["172.16.0.0/16"]
}

module "core_subnet" {
  source              = "../modules/subnet"
  name                = "Core"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.core_vnet.name
  address_prefixes    = ["10.0.0.0/24"]
}

module "mfg_subnet" {
  source              = "../modules/subnet"
  name                = "Manufacturing"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.mfg_vnet.name
  address_prefixes    = ["172.16.0.0/24"]
}
module "perimeter_subnet" {
  source              = "../modules/subnet"
  name                = "perimeter"
  resource_group_name = module.poc_rg.name
  vnet_name           = module.core_vnet.name
  address_prefixes    = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network_peering" "mfg_core_peer" {
  name                         = "ManufacturingVnet-to-CoreServicesVnet"
  virtual_network_name         = module.mfg_vnet.name
  resource_group_name          = module.poc_rg.name
  remote_virtual_network_id    = module.core_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "azurerm_virtual_network_peering" "core_mfg_peer" {
  name                         = "CoreServicesVnet-to-ManufacturingVnet"
  virtual_network_name         = module.core_vnet.name
  resource_group_name          = module.poc_rg.name
  remote_virtual_network_id    = module.mfg_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
resource "random_password" "vm_password" {
  length  = 12
  numeric = true
}
module "core_vm" {
  source              = "../modules/vm"
  resource_group_name = module.poc_rg.name
  password            = random_password.vm_password.result
  location            = module.poc_rg.location
  subnet_id           = module.core_subnet.id
  vm_name             = "CoreServicesVM"
}
module "mfg_vm" {
  source              = "../modules/vm"
  resource_group_name = module.poc_rg.name
  password            = random_password.vm_password.result
  location            = module.poc_rg.location
  subnet_id           = module.mfg_subnet.id
  vm_name             = "ManufacturingVM"
}


resource "azurerm_route_table" "route_table" {
  name                          = "rt-CoreServices"
  location                      = module.poc_rg.location
  resource_group_name           = module.poc_rg.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "PerimetertoCore"
    address_prefix         = "10.0.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.7"
  }
  lifecycle {
    create_before_destroy = false
  }
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  subnet_id      = module.perimeter_subnet.id
  route_table_id = azurerm_route_table.route_table.id
}