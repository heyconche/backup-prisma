# --- VPC NETWORK ---
# Create the main virtual network for the Prisma Hub project
resource "google_compute_network" "main_vpc" {
  name                    = "vpc-prisma-hub"
  auto_create_subnetworks = false # Best practice: create subnets manually
}

# --- SUBNET ---
# Create a specific subnet for our Cloud Functions and SQL
resource "google_compute_subnetwork" "hub_subnet" {
  name          = "subnet-collector-us-central1"
  ip_cidr_range = "10.0.0.0/24" # Internal IP range for our services
  region        = var.region
  network       = google_compute_network.main_vpc.id
}

# --- VPC PEERING (THE BRIDGE) ---
# Create a peering connection for each client defined in your variables
# This allows the GCP to "see" the client's CommServe internal IP
resource "google_compute_network_peering" "client_peering" {
  for_each     = var.commvault_environments
  name         = "peering-to-${each.key}"
  network      = google_compute_network.main_vpc.self_link
  peer_network = "projects/${each.value.client_project_id}/global/networks/${each.value.client_vpc_name}"

  # Important: This allows routes to be shared between the two networks
  export_custom_routes = true
  import_custom_routes = true
}