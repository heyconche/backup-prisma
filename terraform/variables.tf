variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type    = string
  default = "us-central1"
}

# Enhanced map to support VPC Peering automation
variable "commvault_environments" {
  type = map(object({
    db_name           = string # Isolated DB name
    db_user           = string # Isolated DB user
    commserve_ip      = string # Internal IP of the CommServe
    client_project_id = string # GCP Project ID where the client's VPC is located
    client_vpc_name   = string # Name of the client's VPC for peering
  }))
  description = "Multi-tenant configuration for Commvault environments"
}

variable "db_password" {
  type      = string
  sensitive = true
}