# Create a secret for each client to store their Commvault Access Token
# Note: You will manually populate the value once via GCP Console
resource "google_secret_manager_secret" "cv_token" {
  for_each = var.commvault_environments
  secret_id = "cv-token-${each.key}"

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}