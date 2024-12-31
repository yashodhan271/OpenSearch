resource "kubernetes_manifest" "opensearch_cluster" {
  depends_on = [kubernetes_deployment.opensearch_operator]

  manifest = {
    apiVersion = "opensearch.opensearch.org/v1"
    kind       = "OpenSearchCluster"
    metadata = {
      name      = "opensearch-cluster"
      namespace = kubernetes_namespace.opensearch.metadata[0].name
    }
    spec = {
      general = {
        serviceName    = "opensearch-cluster"
        version        = "2.11.0"
        httpPort      = 9200
        dashboardsPort = 5601
      }

      nodeGroups = [
        {
          name        = "master"
          replicas    = 3
          roles       = ["master", "data"]
          diskSize    = "50Gi"
          jvm         = "4g"

          resources = {
            requests = {
              cpu    = "1"
              memory = "8Gi"
            }
            limits = {
              cpu    = "2"
              memory = "8Gi"
            }
          }

          persistence = {
            pvc = {
              storageClassName = "standard-rwo"
            }
          }
        }
      ]
    }
  }
}

# Network Policy for OpenSearch
resource "kubernetes_network_policy" "opensearch" {
  metadata {
    name      = "opensearch-network-policy"
    namespace = kubernetes_namespace.opensearch.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "opensearch.opensearch.org/component" = "opensearch"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.opensearch.metadata[0].name
          }
        }
      }

      ports {
        port     = "9200"
        protocol = "TCP"
      }
      ports {
        port     = "9300"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
