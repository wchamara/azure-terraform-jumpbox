output "csp_resource_group" {
  value = azurerm_resource_group.csp_resource_group[0]
}
output "csp_resource_group_name" {
  value = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].name : data.azurerm_resource_group.csp_resource_group[0].name
}
output "csp_resource_group_id" {
  value = azurerm_resource_group.csp_resource_group[0].id
}
output "management_vm_availability_set_id" {
  value = azurerm_availability_set.management_vm_availability_set.id
}
output "management_server_public_ip_id" {
  value = azurerm_public_ip.management_server_public_ip.id
}
output "management_vm_nic_id" {
  value = azurerm_network_interface.management_vm_nic.id
}
output "management_vm_id" {
  value = azurerm_windows_virtual_machine.management_vm.id
}
output "outbound_connectivity_to_internet_id" {
  value = azurerm_network_security_rule.outbound_connectivity_to_internet.id
}
output "outbound_connectivity_to_customer_Subnets_id" {
  value = azurerm_network_security_rule.outbound_connectivity_to_customer_Subnets.id
}
