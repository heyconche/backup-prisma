output "vpc_id" {
  description = "The ID of the VPC created for the Hub"
  value       = google_compute_network.main_vpc.id
}

output "vpc_self_link" {
  description = "The self-link of the VPC for peering/internal connections"
  value       = google_compute_network.main_vpc.self_link
}