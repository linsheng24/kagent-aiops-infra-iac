data "kubernetes_service_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.grafana]
}

resource "grafana_service_account" "main" {
  name       = "terraform"
  role       = "Admin"
  depends_on = [helm_release.grafana]
}

resource "grafana_service_account_token" "main" {
  name               = "terraform-token"
  service_account_id = grafana_service_account.main.id
}

resource "kubernetes_secret_v1" "grafana_admin" {
  metadata {
    name      = "grafana-admin-credentials"
    namespace = "monitoring"
  }

  data = {
    admin-user     = "admin"
    admin-password = var.grafana_admin_password
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  depends_on = [helm_release.prometheus, kubernetes_secret_v1.grafana_admin]

  values = [
    yamlencode({
      admin = {
        existingSecret = kubernetes_secret_v1.grafana_admin.metadata[0].name
        userKey        = "admin-user"
        passwordKey    = "admin-password"
      }

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              uid       = "prometheus-ds"
              url       = "http://prometheus-server.monitoring.svc.cluster.local"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }

      service = {
        type = "LoadBalancer"
      }
    })
  ]
}
