resource "azurerm_route_table" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  route {
    name                   = "default-via-azure-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.next_hop_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = azurerm_route_table.this.id
}
