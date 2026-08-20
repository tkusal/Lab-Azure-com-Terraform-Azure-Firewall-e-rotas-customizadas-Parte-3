locals {
  public_ips = {
    data       = var.public_ip_name
    management = var.management_public_ip_name
  }
}

resource "azurerm_public_ip" "this" {
  for_each = local.public_ips

  name                = each.value
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                     = var.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku_tier
  threat_intelligence_mode = "Alert"
  tags                     = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = var.rule_collection_group_name
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections

    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules

        content {
          name                  = rule.key
          description           = rule.value.description
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collections

    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules

        content {
          name                  = rule.key
          description           = rule.value.description
          source_addresses      = rule.value.source_addresses
          destination_fqdns     = rule.value.destination_fqdns
          destination_fqdn_tags = rule.value.destination_fqdn_tags

          dynamic "protocols" {
            for_each = rule.value.protocols

            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  tags                = var.tags

  ip_configuration {
    name                 = "data-ip-configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.this["data"].id
  }

  management_ip_configuration {
    name                 = "management-ip-configuration"
    subnet_id            = var.management_subnet_id
    public_ip_address_id = azurerm_public_ip.this["management"].id
  }

  depends_on = [azurerm_firewall_policy_rule_collection_group.this]
}
