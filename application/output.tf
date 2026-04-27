output "vnets" {
  value = {
    app_vnet=module.app_vnet.id
    hub_vnet=module.hub_vnet.id
  }
}