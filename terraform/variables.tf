variable "project_id" {
  description = "ID do Projeto no GCP"
  type        = string
}

variable "region" {
  default     = "southamerica-east1"
  type        = string
}

variable "zone" {
  default     = "southamerica-east1-a"
  type        = string
}

variable "vm_name" {
  description = "Nome exato da VM do Commserve que já existe"
  type        = string
}

variable "domain" {
  description = "Domínio completo (ex: cv.sauter.digital)"
  type        = string
}

variable "resource_prefix" {
  description = "Prefixo para nomear os recursos (ex: prisma-prod)"
  type        = string
}