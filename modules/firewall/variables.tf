variable "name" {
  description = "Nome do Azure Firewall."
  type        = string
}

variable "sku_name" {
  description = "Nome da SKU do Azure Firewall implantado em uma VNet."
  type        = string

  validation {
    condition     = var.sku_name == "AZFW_VNet"
    error_message = "Este modulo usa subnets dedicadas e aceita somente sku_name AZFW_VNet."
  }
}

variable "sku_tier" {
  description = "Tier compartilhado pelo Azure Firewall e pela Firewall Policy."
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier deve ser Basic, Standard ou Premium."
  }
}

variable "policy_name" {
  description = "Nome da Firewall Policy."
  type        = string
}

variable "rule_collection_group_name" {
  description = "Nome do grupo de colecoes de regras da Firewall Policy."
  type        = string
}

variable "public_ip_name" {
  description = "Nome do IP publico usado pelo trafego de dados do firewall."
  type        = string
}

variable "management_public_ip_name" {
  description = "Nome do IP publico usado pelo plano de gerenciamento da SKU Basic."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos do firewall."
  type        = string
}

variable "location" {
  description = "Regiao do Azure do firewall."
  type        = string
}

variable "firewall_subnet_id" {
  description = "ID da subnet AzureFirewallSubnet."
  type        = string
}

variable "management_subnet_id" {
  description = "ID da subnet AzureFirewallManagementSubnet exigida pela SKU Basic."
  type        = string
}

variable "network_rule_collections" {
  description = "Colecoes de regras de rede da Firewall Policy."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      description           = optional(string)
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for collection in values(var.network_rule_collections) : contains(["Allow", "Deny"], collection.action)
    ])
    error_message = "action deve ser Allow ou Deny."
  }
}

variable "application_rule_collections" {
  description = "Colecoes de regras de aplicacao da Firewall Policy."
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      description           = optional(string)
      source_addresses      = list(string)
      destination_fqdns     = optional(list(string), [])
      destination_fqdn_tags = optional(list(string), [])
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for collection in values(var.application_rule_collections) : contains(["Allow", "Deny"], collection.action)
    ])
    error_message = "action deve ser Allow ou Deny."
  }
}

variable "tags" {
  description = "Tags aplicadas aos recursos que aceitam tags."
  type        = map(string)
  default     = {}
}
