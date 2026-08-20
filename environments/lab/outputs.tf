output "resource_group_names" {
  description = "Nomes dos grupos de recursos por papel de rede."
  value       = { for key, group in azurerm_resource_group.network : key => group.name }
}

output "virtual_network_ids" {
  description = "IDs das redes virtuais criadas pelo laboratorio."
  value       = { for key, network in module.virtual_network : key => network.id }
}

output "subnet_ids" {
  description = "IDs das subnets, agrupados por rede virtual."
  value       = { for key, network in module.virtual_network : key => network.subnet_ids }
}

output "peering_ids" {
  description = "IDs dos quatro links direcionais de peering."
  value = {
    hub_to_app  = azurerm_virtual_network_peering.hub_to_app.id
    app_to_hub  = azurerm_virtual_network_peering.app_to_hub.id
    hub_to_data = azurerm_virtual_network_peering.hub_to_data.id
    data_to_hub = azurerm_virtual_network_peering.data_to_hub.id
  }
}

output "network_security_group_ids" {
  description = "IDs dos NSGs por camada da topologia."
  value       = { for key, nsg in module.network_security_group : key => nsg.id }
}

output "firewall_id" {
  description = "ID do Azure Firewall central."
  value       = module.firewall.id
}

output "firewall_private_ip_address" {
  description = "IP privado do firewall usado como next hop das UDRs."
  value       = module.firewall.private_ip_address
}

output "firewall_policy_id" {
  description = "ID da Firewall Policy associada ao firewall."
  value       = module.firewall.policy_id
}

output "route_table_ids" {
  description = "IDs das tabelas de rotas por spoke."
  value       = { for key, route_table in module.route_table : key => route_table.id }
}
