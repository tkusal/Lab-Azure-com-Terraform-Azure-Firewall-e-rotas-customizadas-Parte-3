output "id" {
  description = "ID do Azure Firewall."
  value       = azurerm_firewall.this.id
}

output "private_ip_address" {
  description = "IP privado do Azure Firewall usado como next hop das UDRs."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "policy_id" {
  description = "ID da Firewall Policy."
  value       = azurerm_firewall_policy.this.id
}

output "public_ip_ids" {
  description = "IDs dos IPs publicos de dados e gerenciamento."
  value       = { for key, public_ip in azurerm_public_ip.this : key => public_ip.id }
}
