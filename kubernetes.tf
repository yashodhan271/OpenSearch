provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Create OpenSearch namespace
resource "kubernetes_namespace" "opensearch" {
  metadata {
    name = "opensearch"
  }
}

# OpenSearch Operator ServiceAccount
resource "kubernetes_service_account" "opensearch_operator" {
  metadata {
    name      = "opensearch-operator"
    namespace = kubernetes_namespace.opensearch.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.opensearch_operator.email
    }
  }
}

# OpenSearch Operator ClusterRole
resource "kubernetes_cluster_role" "opensearch_operator" {
  metadata {
    name = "opensearch-operator-role"
  }

  rule {
    api_groups = ["opensearch.opensearch.org"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "persistentvolumeclaims", "events", "configmaps", "secrets"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets"]
    verbs      = ["*"]
  }
}

# OpenSearch Operator ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "opensearch_operator" {
  metadata {
    name = "opensearch-operator-rolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.opensearch_operator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.opensearch_operator.metadata[0].name
    namespace = kubernetes_namespace.opensearch.metadata[0].name
  }
}

# OpenSearch Operator Deployment
resource "kubernetes_deployment" "opensearch_operator" {
  metadata {
    name      = "opensearch-operator"
    namespace = kubernetes_namespace.opensearch.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "control-plane" = "controller-manager"
      }
    }

    template {
      metadata {
        labels = {
          "control-plane" = "controller-manager"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.opensearch_operator.metadata[0].name
        container {
          name  = "manager"
          image = "opensearchproject/opensearch-operator:latest"
          
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
