resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "oci://ghcr.io/prometheus-community/charts"
  chart      = "prometheus"
  namespace  = "monitoring"

  depends_on = [kubernetes_namespace_v1.monitoring]

  values = [
    yamlencode({
      server = {
        global = {
          external_labels = {
            cluster = "linode-k8s"
            replica = "0"
          }
        }
      }

      alertmanagerFiles = {
        "alertmanager.yml" = {
          global = {
            resolve_timeout = "5m"
          }
          route = {
            receiver       = "keep"
            group_wait     = "30s"
            group_interval = "5m"
            repeat_interval = "1h"
          }
          receivers = [
            {
              name = "keep"
              webhook_configs = [
                {
                  url           = "http://keep-backend.keep.svc.cluster.local:8080/alerts/event/prometheus"
                  send_resolved = true
                }
              ]
            }
          ]
        }
      }
    })
  ]
}
