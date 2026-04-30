terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

provider "helm" {
  kubernetes = {
    host                   = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).clusters.0.cluster.server
    cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).clusters.0.cluster.certificate-authority-data)
    token                  = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).users.0.user.token
  }
}

provider "kubernetes" {
  host                   = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).clusters.0.cluster.server
  cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).clusters.0.cluster.certificate-authority-data)
  token                  = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig)).users.0.user.token
}

provider "grafana" {
  url  = "http://${data.kubernetes_service_v1.grafana.status[0].load_balancer[0].ingress[0].ip}"
  auth = "admin:${var.grafana_admin_password}"
}
