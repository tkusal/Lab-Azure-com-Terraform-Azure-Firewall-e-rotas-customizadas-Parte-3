variable "name" {
  description = "Nome da rede virtual."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos da rede virtual."
  type        = string
}

variable "location" {
  description = "Regiao do Azure da rede virtual."
  type        = string
}

variable "address_space" {
  description = "Blocos CIDR da rede virtual."
  type        = list(string)
}

variable "subnets" {
  description = "Mapa de subnets que pertencem a rede virtual."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Tags aplicadas a rede virtual."
  type        = map(string)
  default     = {}
}
