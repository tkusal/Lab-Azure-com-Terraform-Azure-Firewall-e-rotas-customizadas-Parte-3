variable "name" {
  description = "Nome do grupo de seguranca de rede."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos do NSG."
  type        = string
}

variable "location" {
  description = "Regiao do Azure do NSG."
  type        = string
}

variable "security_rules" {
  description = "Mapa de regras de seguranca do NSG."
  type = map(object({
    description                = optional(string)
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) : contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "direction deve ser Inbound ou Outbound."
  }

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) : contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "access deve ser Allow ou Deny."
  }

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) : contains(["*", "Tcp", "Udp", "Icmp", "Ah", "Esp"], rule.protocol)
    ])
    error_message = "protocol deve usar um valor aceito pelo AzureRM."
  }

  validation {
    condition = alltrue([
      for rule in values(var.security_rules) : rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "priority deve estar entre 100 e 4096."
  }

  validation {
    condition = length(distinct([
      for rule in values(var.security_rules) : "${rule.direction}-${rule.priority}"
    ])) == length(var.security_rules)
    error_message = "Cada prioridade deve ser unica dentro da mesma direcao."
  }
}

variable "tags" {
  description = "Tags aplicadas ao NSG."
  type        = map(string)
  default     = {}
}
