variable "project_id" { type = string }
variable "region" { type = string }
variable "db_password" { type = string }
variable "network_id" { type = string } # Passed from networking module output
variable "commvault_environments" { type = map(any) }