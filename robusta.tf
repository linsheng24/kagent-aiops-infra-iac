resource "helm_release" "robusta" {
  name             = "robusta"
  repository       = "https://robusta-charts.storage.googleapis.com"
  chart            = "robusta"
  namespace        = "robusta"
  create_namespace = true

  values = [
    yamlencode({
      clusterName = linode_lke_cluster.cluster.label

      globalConfig = {
        signing_key = var.robusta_signing_key
        account_id  = "00000000-0000-0000-0000-000000000000"
      }

      sinksConfig = [
        {
          discord_sink = {
            name = "discord"
            url  = var.discord_webhook_url
          }
        }
      ]

      # Don't install bundled Prometheus stack — we have our own
      enablePrometheusStack = false
    })
  ]
}
