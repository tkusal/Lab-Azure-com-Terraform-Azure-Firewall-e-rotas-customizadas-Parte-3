variable "subscription_id" {
  description = "ID da assinatura do Azure usada pelo laboratorio."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id deve ser um GUID valido."
  }
}

variable "location" {
  description = "Regiao do Azure para os recursos do laboratorio."
  type        = string
  default     = "brazilsouth"
}

variable "location_code" {
  description = "Codigo curto da regiao usado nos nomes dos recursos."
  type        = string
  default     = "brs"
}

variable "environment" {
  description = "Nome curto do ambiente."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "dev", "test", "prod"], var.environment)
    error_message = "environment deve ser lab, dev, test ou prod."
  }
}

variable "owner" {
  description = "Pessoa ou equipe responsavel pelos recursos."
  type        = string
}

variable "cost_center" {
  description = "Centro de custo ou identificador financeiro do laboratorio."
  type        = string
  default     = "learning"
}

variable "extra_tags" {
  description = "Tags adicionais aplicadas aos recursos que aceitam tags."
  type        = map(string)
  default     = {}
}
