output "id" {
  description = "ID da tabela de rotas."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Nome da tabela de rotas."
  value       = azurerm_route_table.this.name
}

output "association_ids" {
  description = "IDs das associacoes entre subnets e a tabela de rotas."
  value       = { for key, association in azurerm_subnet_route_table_association.this : key => association.id }
}
