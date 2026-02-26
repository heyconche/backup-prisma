# --- TERRAFORM SETTINGS & BACKEND ---
terraform {
  # Stores the state file in GCS to prevent resource duplication and allow collaboration
  backend "gcs" {
    bucket  = "sauter-prisma-hub-tfstate"
    prefix  = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# --- PROVIDER CONFIGURATION ---
provider "google" {
  project = var.project_id
  region  = var.region
}

# --- API ENABLER ---
# Activates all necessary Google Cloud services before provisioning resources
resource "google_project_service" "required_apis" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "vpcaccess.googleapis.com" # Required for Cloud Functions to access VPC
  ])
  service = each.key
  disable_on_destroy = false
}

# --- MODULE: NETWORKING ---
# Provisions the VPC, Subnets, and Peerings for all clients
module "networking" {
  source                 = "./modules/networking"
  project_id             = var.project_id
  region                 = var.region
  commvault_environments = var.commvault_environments
  
  # Ensures APIs are active before creating network resources
  depends_on = [google_project_service.required_apis]
}

# --- MODULE: DATABASE ---
# Provisions Cloud SQL instances and client-specific databases (schemas)
module "database" {
  source                 = "./modules/database"
  project_id             = var.project_id
  region                 = var.region
  db_password            = var.db_password
  commvault_environments = var.commvault_environments
  network_id             = module.networking.vpc_id # Connects SQL to our VPC
  
  depends_on = [module.networking]
}

# --- MODULE: SECRETS ---
# Provisions Secret Manager envelopes for Access/Refresh tokens
module "secrets" {
  source                 = "./modules/secrets"
  project_id             = var.project_id
  commvault_environments = var.commvault_environments
}