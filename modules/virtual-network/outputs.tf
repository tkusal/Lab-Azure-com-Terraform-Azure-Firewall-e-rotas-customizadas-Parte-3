output "id" {
  description = "ID da rede virtual."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "Nome da rede virtual."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Nome do grupo de recursos da rede virtual."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "subnet_ids" {
  description = "Mapa de IDs das subnets."
  value       = { for key, subnet in azurerm_subnet.this : key => subnet.id }
}
