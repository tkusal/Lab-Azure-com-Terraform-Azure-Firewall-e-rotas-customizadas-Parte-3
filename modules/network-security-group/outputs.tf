output "id" {
  description = "ID do grupo de seguranca de rede."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "Nome do grupo de seguranca de rede."
  value       = azurerm_network_security_group.this.name
}
