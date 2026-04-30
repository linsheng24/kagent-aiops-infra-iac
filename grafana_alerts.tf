resource "grafana_contact_point" "keep" {
  name       = "Keep"
  depends_on = [helm_release.grafana]

  webhook {
    url                       = "http://keep-backend.keep.svc.cluster.local:8080/alerts/event/grafana"
    http_method               = "POST"
    authorization_scheme      = "Bearer"
    authorization_credentials = var.keep_secret_key
  }
}

resource "grafana_notification_policy" "main" {
  group_by      = ["alertname", "instance"]
  contact_point = grafana_contact_point.keep.name

  group_wait      = "30s"
  group_interval  = "5m"
  repeat_interval = "1h"
}

resource "grafana_rule_group" "node_resources" {
  name             = "Node Resources"
  folder_uid       = grafana_folder.k8s.uid
  interval_seconds = 60

  depends_on = [grafana_folder.k8s]

  # ── CPU Warning > 80% ────────────────────────────────────────────────────
  rule {
    name      = "Node CPU Warning"
    condition = "threshold"
    for       = "30s"

    annotations = {
      summary     = "High CPU on {{ $labels.instance }}"
      description = "CPU usage {{ $values.reduce.Value | humanizePercentage }} (threshold 80%)"
    }
    labels = { severity = "warning" }

    data {
      ref_id         = "query"
      datasource_uid = local.prometheus_ds_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr          = "1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))"
        refId         = "query"
        intervalMs    = 1000
        maxDataPoints = 43200
      })
    }
    data {
      ref_id         = "reduce"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "reduce"
        expression = "query"
        reducer    = "last"
        refId      = "reduce"
        datasource = { type = "__expr__", uid = "__expr__" }
        settings   = { mode = "" }
      })
    }
    data {
      ref_id         = "threshold"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "reduce"
        refId      = "threshold"
        datasource = { type = "__expr__", uid = "__expr__" }
        conditions = [{ evaluator = { params = [0.8], type = "gt" } }]
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
  }

  # ── CPU Critical > 90% ───────────────────────────────────────────────────
  rule {
    name      = "Node CPU Critical"
    condition = "threshold"
    for       = "30s"

    annotations = {
      summary     = "Critical CPU on {{ $labels.instance }}"
      description = "CPU usage {{ $values.reduce.Value | humanizePercentage }} (threshold 90%)"
    }
    labels = { severity = "critical" }

    data {
      ref_id         = "query"
      datasource_uid = local.prometheus_ds_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr          = "1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m]))"
        refId         = "query"
        intervalMs    = 1000
        maxDataPoints = 43200
      })
    }
    data {
      ref_id         = "reduce"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "reduce"
        expression = "query"
        reducer    = "last"
        refId      = "reduce"
        datasource = { type = "__expr__", uid = "__expr__" }
        settings   = { mode = "" }
      })
    }
    data {
      ref_id         = "threshold"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "reduce"
        refId      = "threshold"
        datasource = { type = "__expr__", uid = "__expr__" }
        conditions = [{ evaluator = { params = [0.9], type = "gt" } }]
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
  }

  # ── Memory Warning > 80% ─────────────────────────────────────────────────
  rule {
    name      = "Node Memory Warning"
    condition = "threshold"
    for       = "30s"

    annotations = {
      summary     = "High memory on {{ $labels.instance }}"
      description = "Memory usage {{ $values.reduce.Value | humanizePercentage }} (threshold 80%)"
    }
    labels = { severity = "warning" }

    data {
      ref_id         = "query"
      datasource_uid = local.prometheus_ds_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr          = "1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)"
        refId         = "query"
        intervalMs    = 1000
        maxDataPoints = 43200
      })
    }
    data {
      ref_id         = "reduce"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "reduce"
        expression = "query"
        reducer    = "last"
        refId      = "reduce"
        datasource = { type = "__expr__", uid = "__expr__" }
        settings   = { mode = "" }
      })
    }
    data {
      ref_id         = "threshold"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "reduce"
        refId      = "threshold"
        datasource = { type = "__expr__", uid = "__expr__" }
        conditions = [{ evaluator = { params = [0.8], type = "gt" } }]
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
  }

  # ── Memory Critical > 90% ────────────────────────────────────────────────
  rule {
    name      = "Node Memory Critical"
    condition = "threshold"
    for       = "30s"

    annotations = {
      summary     = "Critical memory on {{ $labels.instance }}"
      description = "Memory usage {{ $values.reduce.Value | humanizePercentage }} (threshold 90%)"
    }
    labels = { severity = "critical" }

    data {
      ref_id         = "query"
      datasource_uid = local.prometheus_ds_uid
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        expr          = "1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)"
        refId         = "query"
        intervalMs    = 1000
        maxDataPoints = 43200
      })
    }
    data {
      ref_id         = "reduce"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "reduce"
        expression = "query"
        reducer    = "last"
        refId      = "reduce"
        datasource = { type = "__expr__", uid = "__expr__" }
        settings   = { mode = "" }
      })
    }
    data {
      ref_id         = "threshold"
      datasource_uid = "__expr__"
      relative_time_range {
        from = 300
        to   = 0
      }
      model = jsonencode({
        type       = "threshold"
        expression = "reduce"
        refId      = "threshold"
        datasource = { type = "__expr__", uid = "__expr__" }
        conditions = [{ evaluator = { params = [0.9], type = "gt" } }]
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
  }
}
