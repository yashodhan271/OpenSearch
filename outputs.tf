output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "opensearch_namespace" {
  description = "Kubernetes namespace where OpenSearch is deployed"
  value       = kubernetes_namespace.opensearch.metadata[0].name
}

output "opensearch_service" {
  description = "OpenSearch service name"
  value       = "opensearch-cluster-master"
}
