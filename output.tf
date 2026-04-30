output "cluster_name" {
  description = "The name of the Linode LKE cluster"
  value       = linode_lke_cluster.cluster.label
}

output "cluster_id" {
  description = "The ID of the Linode LKE cluster"
  value       = linode_lke_cluster.cluster.id
}

output "token" {
  description = "Token for the linode provider"
  value       = var.linode_token
}

output "grafana_api_token" {
  description = "Grafana service account API token"
  value       = grafana_service_account_token.main.key
  sensitive   = true
}
