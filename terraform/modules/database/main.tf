# --- CLOUD SQL INSTANCE ---
# Provisioning the main instance with Private IP only for security
resource "google_sql_database_instance" "main_instance" {
  name             = "sql-prisma-hub"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro" # Cost-effective tier for testing
    ip_configuration {
      ipv4_enabled    = false            # Disables public internet access
      private_network = var.network_id   # Connects instance to our Hub VPC
    }
  }
}

# --- CLIENT DATABASES (SCHEMAS) ---
# Creates an isolated database for each client entry in the map
resource "google_sql_database" "client_db" {
  for_each = var.commvault_environments
  name     = each.value.db_name
  instance = google_sql_database_instance.main_instance.name # References the instance above
}

# --- CLIENT USERS ---
# Creates a dedicated user for each client database
resource "google_sql_user" "client_user" {
  for_each = var.commvault_environments
  name     = each.value.db_user
  instance = google_sql_database_instance.main_instance.name
  password = var.db_password
}

# NOTE: The null_resource was removed. 
# Table creation is now handled by Python using 'ensure_schema_exists'.