# terraform/variables.tf

# Project ID on Google Cloud
variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

# Regional location for resources
variable "region" {
  type    = string
  default = "us-central1"
}

# Map of client environments (The multi-tenant structure)
variable "commvault_environments" {
  type = map(object({
    db_name      = string # Database name for isolation
    db_user      = string # Database user for isolation
    commserve_ip = string # Internal IP for VPC Peering/VPN access
  }))
  description = "List of clients to be provisioned"
}

# Master password for all database users
variable "db_password" {
  type      = string
  sensitive = true # Prevents the password from appearing in logs
}