variable "name" {
  description = "Nome da tabela de rotas."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos da tabela de rotas."
  type        = string
}

variable "location" {
  description = "Regiao do Azure da tabela de rotas."
  type        = string
}

variable "next_hop_ip_address" {
  description = "IP privado do virtual appliance usado como proximo salto."
  type        = string
}

variable "subnet_ids" {
  description = "Mapa de IDs das subnets associadas a tabela de rotas."
  type        = map(string)
}

variable "tags" {
  description = "Tags aplicadas a tabela de rotas."
  type        = map(string)
  default     = {}
}
