locals {
  common_tags = merge(
    {
      environment = var.environment
      owner       = var.owner
      cost-center = var.cost_center
      managed-by  = "terraform"
      project     = "azure-hub-spoke-lab"
    },
    var.extra_tags
  )

  networks = {
    hub = {
      resource_group_name = "rg-network-hub-${var.environment}-${var.location_code}-001"
      vnet_name           = "vnet-hub-${var.environment}-${var.location_code}-001"
      role                = "hub"
      address_space       = ["10.64.0.0/16"]
      subnets = {
        firewall = {
          name             = "AzureFirewallSubnet"
          address_prefixes = ["10.64.0.0/26"]
        }
        firewall_management = {
          name             = "AzureFirewallManagementSubnet"
          address_prefixes = ["10.64.1.0/26"]
        }
        shared = {
          name             = "snet-shared-${var.environment}-${var.location_code}-001"
          address_prefixes = ["10.64.10.0/24"]
        }
      }
    }
    spoke_app = {
      resource_group_name = "rg-network-app-${var.environment}-${var.location_code}-001"
      vnet_name           = "vnet-app-${var.environment}-${var.location_code}-001"
      role                = "spoke"
      address_space       = ["10.65.0.0/16"]
      subnets = {
        web = {
          name             = "snet-web-${var.environment}-${var.location_code}-001"
          address_prefixes = ["10.65.10.0/24"]
        }
        app = {
          name             = "snet-app-${var.environment}-${var.location_code}-001"
          address_prefixes = ["10.65.20.0/24"]
        }
      }
    }
    spoke_data = {
      resource_group_name = "rg-network-data-${var.environment}-${var.location_code}-001"
      vnet_name           = "vnet-data-${var.environment}-${var.location_code}-001"
      role                = "spoke"
      address_space       = ["10.66.0.0/16"]
      subnets = {
        data = {
          name             = "snet-data-${var.environment}-${var.location_code}-001"
          address_prefixes = ["10.66.10.0/24"]
        }
        integration = {
          name             = "snet-integration-${var.environment}-${var.location_code}-001"
          address_prefixes = ["10.66.20.0/24"]
        }
      }
    }
  }

  network_security_groups = {
    web = {
      name        = "nsg-web-${var.environment}-${var.location_code}-001"
      network_key = "spoke_app"
      subnet_key  = "web"
      rules = {
        allow-https-from-internet = {
          description                = "Permite HTTPS da Internet para a camada web."
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "10.65.10.0/24"
        }
        deny-all-inbound = {
          description                = "Nega qualquer outra entrada."
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow-app-outbound = {
          description                = "Permite chamadas da camada web para a camada de aplicacao."
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "8080"
          source_address_prefix      = "10.65.10.0/24"
          destination_address_prefix = "10.65.20.0/24"
        }
        allow-windows-update-http = {
          description                = "Permite HTTP para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "10.65.10.0/24"
          destination_address_prefix = "Internet"
        }
        allow-windows-update-https = {
          description                = "Permite HTTPS para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "10.65.10.0/24"
          destination_address_prefix = "Internet"
        }
        deny-all-outbound = {
          description                = "Nega qualquer outra saida."
          priority                   = 4096
          direction                  = "Outbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
    app = {
      name        = "nsg-app-${var.environment}-${var.location_code}-001"
      network_key = "spoke_app"
      subnet_key  = "app"
      rules = {
        allow-web-inbound = {
          description                = "Permite chamadas da camada web para a camada de aplicacao."
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "8080"
          source_address_prefix      = "10.65.10.0/24"
          destination_address_prefix = "10.65.20.0/24"
        }
        deny-all-inbound = {
          description                = "Nega qualquer outra entrada."
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow-data-outbound = {
          description                = "Permite SQL da camada de aplicacao para a camada de dados pelo firewall."
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "1433"
          source_address_prefix      = "10.65.20.0/24"
          destination_address_prefix = "10.66.10.0/24"
        }
        allow-windows-update-http = {
          description                = "Permite HTTP para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "10.65.20.0/24"
          destination_address_prefix = "Internet"
        }
        allow-windows-update-https = {
          description                = "Permite HTTPS para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "10.65.20.0/24"
          destination_address_prefix = "Internet"
        }
        deny-all-outbound = {
          description                = "Nega qualquer saida iniciada pela camada de aplicacao."
          priority                   = 4096
          direction                  = "Outbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
    data = {
      name        = "nsg-data-${var.environment}-${var.location_code}-001"
      network_key = "spoke_data"
      subnet_key  = "data"
      rules = {
        allow-integration-inbound = {
          description                = "Permite SQL da camada de integracao para a camada de dados."
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "1433"
          source_address_prefix      = "10.66.20.0/24"
          destination_address_prefix = "10.66.10.0/24"
        }
        allow-app-inbound = {
          description                = "Permite SQL da camada de aplicacao pelo firewall."
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "1433"
          source_address_prefix      = "10.65.20.0/24"
          destination_address_prefix = "10.66.10.0/24"
        }
        deny-all-inbound = {
          description                = "Nega qualquer outra entrada."
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow-windows-update-http = {
          description                = "Permite HTTP para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "10.66.10.0/24"
          destination_address_prefix = "Internet"
        }
        allow-windows-update-https = {
          description                = "Permite HTTPS para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "10.66.10.0/24"
          destination_address_prefix = "Internet"
        }
        deny-all-outbound = {
          description                = "Nega qualquer saida iniciada pela camada de dados."
          priority                   = 4096
          direction                  = "Outbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
    integration = {
      name        = "nsg-integration-${var.environment}-${var.location_code}-001"
      network_key = "spoke_data"
      subnet_key  = "integration"
      rules = {
        allow-https-from-shared = {
          description                = "Permite HTTPS da subnet compartilhada do hub."
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "10.64.10.0/24"
          destination_address_prefix = "10.66.20.0/24"
        }
        deny-all-inbound = {
          description                = "Nega qualquer outra entrada."
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
        allow-data-outbound = {
          description                = "Permite SQL da camada de integracao para a camada de dados."
          priority                   = 100
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "1433"
          source_address_prefix      = "10.66.20.0/24"
          destination_address_prefix = "10.66.10.0/24"
        }
        allow-windows-update-http = {
          description                = "Permite HTTP para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "10.66.20.0/24"
          destination_address_prefix = "Internet"
        }
        allow-windows-update-https = {
          description                = "Permite HTTPS para endpoints publicos avaliados pelo Azure Firewall."
          priority                   = 120
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "10.66.20.0/24"
          destination_address_prefix = "Internet"
        }
        deny-all-outbound = {
          description                = "Nega qualquer outra saida."
          priority                   = 4096
          direction                  = "Outbound"
          access                     = "Deny"
          protocol                   = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }

  route_tables = {
    spoke_app = {
      name        = "rt-spoke-app-${var.environment}-${var.location_code}-001"
      network_key = "spoke_app"
      subnet_keys = toset(["web", "app"])
    }
    spoke_data = {
      name        = "rt-spoke-data-${var.environment}-${var.location_code}-001"
      network_key = "spoke_data"
      subnet_keys = toset(["data", "integration"])
    }
  }
}

resource "azurerm_resource_group" "network" {
  for_each = local.networks

  name     = each.value.resource_group_name
  location = var.location
  tags     = merge(local.common_tags, { network-role = each.value.role })
}

module "virtual_network" {
  source   = "../../modules/virtual-network"
  for_each = local.networks

  name                = each.value.vnet_name
  resource_group_name = azurerm_resource_group.network[each.key].name
  location            = azurerm_resource_group.network[each.key].location
  address_space       = each.value.address_space
  subnets             = each.value.subnets
  tags                = merge(local.common_tags, { network-role = each.value.role })
}

module "network_security_group" {
  source   = "../../modules/network-security-group"
  for_each = local.network_security_groups

  name                = each.value.name
  resource_group_name = module.virtual_network[each.value.network_key].resource_group_name
  location            = var.location
  security_rules      = each.value.rules
  tags                = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.network_security_groups

  subnet_id                 = module.virtual_network[each.value.network_key].subnet_ids[each.value.subnet_key]
  network_security_group_id = module.network_security_group[each.key].id
}

module "firewall" {
  source = "../../modules/firewall"

  name                       = "afw-hub-${var.environment}-${var.location_code}-001"
  sku_name                   = "AZFW_VNet"
  sku_tier                   = "Basic"
  policy_name                = "afwp-hub-${var.environment}-${var.location_code}-001"
  rule_collection_group_name = "rcg-baseline-${var.environment}-${var.location_code}-001"
  public_ip_name             = "pip-afw-${var.environment}-${var.location_code}-001"
  management_public_ip_name  = "pip-afw-management-${var.environment}-${var.location_code}-001"
  resource_group_name        = module.virtual_network["hub"].resource_group_name
  location                   = var.location
  firewall_subnet_id         = module.virtual_network["hub"].subnet_ids["firewall"]
  management_subnet_id       = module.virtual_network["hub"].subnet_ids["firewall_management"]
  tags                       = merge(local.common_tags, { network-role = "hub" })

  network_rule_collections = {
    allow-east-west = {
      priority = 100
      action   = "Allow"
      rules = {
        allow-app-to-data = {
          description           = "Permite SQL da camada de aplicacao para a camada de dados."
          protocols             = ["TCP"]
          source_addresses      = ["10.65.20.0/24"]
          destination_addresses = ["10.66.10.0/24"]
          destination_ports     = ["1433"]
        }
      }
    }
  }

  application_rule_collections = {
    allow-system-updates = {
      priority = 200
      action   = "Allow"
      rules = {
        allow-windows-update = {
          description           = "Permite endpoints mantidos pela tag FQDN WindowsUpdate."
          source_addresses      = ["10.65.0.0/16", "10.66.0.0/16"]
          destination_fqdn_tags = ["WindowsUpdate"]
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
        }
      }
    }
  }
}

module "route_table" {
  source   = "../../modules/route-table"
  for_each = local.route_tables

  name                = each.value.name
  resource_group_name = module.virtual_network[each.value.network_key].resource_group_name
  location            = var.location
  next_hop_ip_address = module.firewall.private_ip_address
  subnet_ids = {
    for subnet_key in each.value.subnet_keys :
    subnet_key => module.virtual_network[each.value.network_key].subnet_ids[subnet_key]
  }
  tags = local.common_tags
}

resource "azurerm_virtual_network_peering" "hub_to_app" {
  name                      = "peer-hub-to-app-${var.environment}-${var.location_code}-001"
  resource_group_name       = module.virtual_network["hub"].resource_group_name
  virtual_network_name      = module.virtual_network["hub"].name
  remote_virtual_network_id = module.virtual_network["spoke_app"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "app_to_hub" {
  name                      = "peer-app-to-hub-${var.environment}-${var.location_code}-001"
  resource_group_name       = module.virtual_network["spoke_app"].resource_group_name
  virtual_network_name      = module.virtual_network["spoke_app"].name
  remote_virtual_network_id = module.virtual_network["hub"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.hub_to_app]
}

resource "azurerm_virtual_network_peering" "hub_to_data" {
  name                      = "peer-hub-to-data-${var.environment}-${var.location_code}-001"
  resource_group_name       = module.virtual_network["hub"].resource_group_name
  virtual_network_name      = module.virtual_network["hub"].name
  remote_virtual_network_id = module.virtual_network["spoke_data"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.hub_to_app]
}

resource "azurerm_virtual_network_peering" "data_to_hub" {
  name                      = "peer-data-to-hub-${var.environment}-${var.location_code}-001"
  resource_group_name       = module.virtual_network["spoke_data"].resource_group_name
  virtual_network_name      = module.virtual_network["spoke_data"].name
  remote_virtual_network_id = module.virtual_network["hub"].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.hub_to_data]
}
