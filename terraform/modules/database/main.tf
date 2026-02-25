# Provision a dedicated database for each client in the map
resource "google_sql_database" "client_db" {
  for_each = var.commvault_environments
  name     = each.value.db_name
  instance = var.cloud_sql_instance_id
}

# Provision a dedicated database user for each client
resource "google_sql_user" "client_user" {
  for_each = var.commvault_environments
  name     = each.value.db_user
  instance = var.cloud_sql_instance_id
  password = var.db_password
}

# Execute schema creation after database is ready
resource "null_resource" "db_setup" {
  for_each = var.commvault_environments
  provisioner "local-exec" {
    # Connects to Cloud SQL and runs the schema.sql script
    command = "mysql -h ${var.db_host} -u ${each.value.db_user} -p'${var.db_password}' ${each.value.db_name} < ../sql/schema.sql"
  }
  depends_on = [google_sql_database.client_db]
}