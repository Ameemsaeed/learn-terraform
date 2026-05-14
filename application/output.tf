# output "vnets" {
#   value = {
#     app_vnet=module.app_vnet.id
#     hub_vnet=module.hub_vnet.id
#   }
# }
output "password" {
  value     = random_password.vm_password.result
  sensitive = true
}