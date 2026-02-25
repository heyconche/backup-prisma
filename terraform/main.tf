# Google Cloud Provider configuration
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required Google Cloud APIs automatically
# This ensures the project is ready for SQL and Functions
resource "google_project_service" "required_apis" {
  for_each = toset([
    "sqladmin.googleapis.com",      # For Cloud SQL management
    "cloudfunctions.googleapis.com", # For Collector logic
    "cloudscheduler.googleapis.com", # For Automated triggers
    "secretmanager.googleapis.com",  # For Token security
    "compute.googleapis.com"         # For VPC Networking
  ])
  service = each.key
  disable_on_destroy = false
}