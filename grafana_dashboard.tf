locals {
  prometheus_ds_uid = "prometheus-ds"
}

resource "grafana_folder" "k8s" {
  title      = "Kubernetes"
  depends_on = [helm_release.grafana]
}

resource "grafana_dashboard" "k8s_overview" {
  folder     = grafana_folder.k8s.uid
  depends_on = [grafana_folder.k8s]

  config_json = jsonencode({
    title         = "Kubernetes Cluster Overview"
    uid           = "k8s-overview"
    schemaVersion = 39
    refresh       = "30s"
    time          = { from = "now-1h", to = "now" }

    panels = [
      # ── Cluster Overview Stats ────────────────────────────────────────────
      {
        id      = 1
        type    = "stat"
        title   = "Nodes"
        gridPos = { x = 0, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            color      = { mode = "fixed", fixedColor = "blue" }
            thresholds = { mode = "absolute", steps = [{ color = "blue", value = null }] }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          colorMode     = "background"
          graphMode     = "none"
          textMode      = "auto"
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "count(kube_node_info)"
          legendFormat = "Nodes"
          instant      = true
        }]
      },
      {
        id      = 2
        type    = "stat"
        title   = "Running Pods"
        gridPos = { x = 4, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            color      = { mode = "fixed", fixedColor = "green" }
            thresholds = { mode = "absolute", steps = [{ color = "green", value = null }] }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          colorMode     = "background"
          graphMode     = "none"
          textMode      = "auto"
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "sum(kube_pod_status_phase{phase=\"Running\"})"
          legendFormat = "Running"
          instant      = true
        }]
      },
      {
        id      = 3
        type    = "stat"
        title   = "Pending Pods"
        gridPos = { x = 8, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            color      = { mode = "fixed", fixedColor = "yellow" }
            thresholds = { mode = "absolute", steps = [{ color = "yellow", value = null }] }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          colorMode     = "background"
          graphMode     = "none"
          textMode      = "auto"
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "sum(kube_pod_status_phase{phase=\"Pending\"})"
          legendFormat = "Pending"
          instant      = true
        }]
      },
      {
        id      = 4
        type    = "stat"
        title   = "Failed Pods"
        gridPos = { x = 12, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            color      = { mode = "fixed", fixedColor = "red" }
            thresholds = { mode = "absolute", steps = [{ color = "red", value = null }] }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          colorMode     = "background"
          graphMode     = "none"
          textMode      = "auto"
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "sum(kube_pod_status_phase{phase=\"Failed\"})"
          legendFormat = "Failed"
          instant      = true
        }]
      },
      {
        id      = 5
        type    = "gauge"
        title   = "Cluster CPU Usage"
        gridPos = { x = 16, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit = "percentunit"
            min  = 0
            max  = 1
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 0.7 },
                { color = "red", value = 0.9 },
              ]
            }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          showThresholdLabels  = false
          showThresholdMarkers = true
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "1 - avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))"
          legendFormat = "CPU"
          instant      = true
        }]
      },
      {
        id      = 6
        type    = "gauge"
        title   = "Cluster Memory Usage"
        gridPos = { x = 20, y = 0, w = 4, h = 4 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit = "percentunit"
            min  = 0
            max  = 1
            thresholds = {
              mode = "absolute"
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 0.7 },
                { color = "red", value = 0.9 },
              ]
            }
          }
        }
        options = {
          reduceOptions = { calcs = ["lastNotNull"] }
          showThresholdLabels  = false
          showThresholdMarkers = true
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "1 - sum(node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes)"
          legendFormat = "Memory"
          instant      = true
        }]
      },

      # ── Node CPU & Memory ─────────────────────────────────────────────────
      {
        id      = 7
        type    = "timeseries"
        title   = "CPU Usage per Node"
        gridPos = { x = 0, y = 4, w = 12, h = 8 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit  = "percentunit"
            min   = 0
            max   = 1
            color = { mode = "palette-classic" }
            custom = {
              lineWidth   = 2
              fillOpacity = 10
            }
          }
        }
        options = {
          tooltip = { mode = "multi", sort = "desc" }
          legend  = { displayMode = "list", placement = "bottom" }
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))"
          legendFormat = "{{instance}}"
        }]
      },
      {
        id      = 8
        type    = "timeseries"
        title   = "Memory Usage per Node"
        gridPos = { x = 12, y = 4, w = 12, h = 8 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit  = "percentunit"
            min   = 0
            max   = 1
            color = { mode = "palette-classic" }
            custom = {
              lineWidth   = 2
              fillOpacity = 10
            }
          }
        }
        options = {
          tooltip = { mode = "multi", sort = "desc" }
          legend  = { displayMode = "list", placement = "bottom" }
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)"
          legendFormat = "{{instance}}"
        }]
      },

      # ── Node Disk & Network ───────────────────────────────────────────────
      {
        id      = 9
        type    = "timeseries"
        title   = "Disk Usage per Node"
        gridPos = { x = 0, y = 12, w = 12, h = 8 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit  = "percentunit"
            min   = 0
            max   = 1
            color = { mode = "palette-classic" }
            custom = {
              lineWidth   = 2
              fillOpacity = 10
            }
          }
        }
        options = {
          tooltip = { mode = "multi", sort = "desc" }
          legend  = { displayMode = "list", placement = "bottom" }
        }
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "1 - (node_filesystem_avail_bytes{mountpoint=\"/\",fstype!=\"tmpfs\"} / node_filesystem_size_bytes{mountpoint=\"/\",fstype!=\"tmpfs\"})"
          legendFormat = "{{instance}}"
        }]
      },
      {
        id      = 10
        type    = "timeseries"
        title   = "Network I/O per Node"
        gridPos = { x = 12, y = 12, w = 12, h = 8 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = {
            unit  = "Bps"
            color = { mode = "palette-classic" }
            custom = {
              lineWidth   = 2
              fillOpacity = 10
            }
          }
        }
        options = {
          tooltip = { mode = "multi", sort = "desc" }
          legend  = { displayMode = "list", placement = "bottom" }
        }
        targets = [
          {
            refId        = "A"
            datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
            expr         = "rate(node_network_receive_bytes_total{device!~\"lo|veth.*\"}[5m])"
            legendFormat = "rx {{instance}} {{device}}"
          },
          {
            refId        = "B"
            datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
            expr         = "-rate(node_network_transmit_bytes_total{device!~\"lo|veth.*\"}[5m])"
            legendFormat = "tx {{instance}} {{device}}"
          },
        ]
      },

      # ── Pod Overview ──────────────────────────────────────────────────────
      {
        id      = 11
        type    = "table"
        title   = "Pods by Namespace & Phase"
        gridPos = { x = 0, y = 20, w = 24, h = 8 }
        datasource = { type = "prometheus", uid = local.prometheus_ds_uid }
        fieldConfig = {
          defaults = { custom = { align = "auto" } }
          overrides = [
            {
              matcher    = { id = "byName", options = "Running" }
              properties = [{ id = "custom.width", value = 100 }, { id = "color", value = { fixedColor = "green", mode = "fixed" } }]
            },
            {
              matcher    = { id = "byName", options = "Pending" }
              properties = [{ id = "custom.width", value = 100 }, { id = "color", value = { fixedColor = "yellow", mode = "fixed" } }]
            },
            {
              matcher    = { id = "byName", options = "Failed" }
              properties = [{ id = "custom.width", value = 100 }, { id = "color", value = { fixedColor = "red", mode = "fixed" } }]
            },
          ]
        }
        options = {
          sortBy  = [{ displayName = "namespace" }]
          footer  = { show = false }
        }
        transformations = [
          { id = "labelsToFields", options = { valueLabel = "phase" } },
          { id = "organize", options = { renameByName = { "namespace" = "Namespace", "Running" = "Running", "Pending" = "Pending", "Failed" = "Failed", "Succeeded" = "Succeeded" } } },
        ]
        targets = [{
          refId        = "A"
          datasource   = { type = "prometheus", uid = local.prometheus_ds_uid }
          expr         = "sum by (namespace, phase) (kube_pod_status_phase) > 0"
          legendFormat = "{{namespace}} {{phase}}"
          instant      = true
          format       = "table"
        }]
      },
    ]
  })
}
