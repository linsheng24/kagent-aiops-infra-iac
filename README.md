# prom-thanos-sidecar-iac

Terraform infrastructure for a Linode LKE cluster with long-term metrics using Prometheus + Thanos (sidecar mode) + Grafana.

Thanos is deployed in **sidecar mode**: a Thanos Sidecar runs alongside Prometheus in the same pod, shipping TSDB blocks to S3 object storage without requiring remote write.

## Architecture

```
┌─────────────────────────────────┐
│       Prometheus Pod            │
│  ┌────────────┐  ┌───────────┐  │
│  │ Prometheus │  │  Thanos   │  │
│  │  :9090     │←→│  Sidecar  │  │
│  │            │  │  :10901   │  │
│  └────────────┘  └─────┬─────┘  │
│   local TSDB (2h block)│        │
└────────────────────────┼────────┘
                         │ upload blocks (every 2h)
                         ▼
                      AWS S3
                         │
              ┌──────────┴──────────┐
              │                     │
     ┌────────▼────────┐   ┌────────▼────────┐
     │  Thanos Store   │   │  Thanos         │
     │  Gateway        │   │  Compactor      │
     │  (serve S3 data)│   │  (compact/      │
     └────────┬────────┘   │   downsample)   │
              │            └─────────────────┘
              │
     ┌────────▼────────┐
     │  Thanos Query   │←── also queries Sidecar gRPC
     │  (fan-out query)│
     └────────┬────────┘
              │
     ┌────────▼────────┐
     │     Grafana     │
     └─────────────────┘
```

### Thanos Components

| Component | Role |
|---|---|
| **Sidecar** | Runs in the Prometheus pod. Reads local TSDB and uploads completed blocks (every 2h) to S3. Exposes gRPC for Thanos Query to read recent data. |
| **Store Gateway** | Reads historical blocks from S3 and exposes them via gRPC to Thanos Query. Enables querying data beyond Prometheus local retention. |
| **Compactor** | Runs as a singleton against S3. Merges small blocks, applies downsampling (5m, 1h resolution) for faster long-range queries. |
| **Query** | Fan-out query layer. Deduplicates results from Sidecar and Store Gateway, exposing a single Prometheus-compatible API to Grafana. |

### Data Flow

1. Prometheus scrapes metrics and writes to local TSDB
2. Thanos Sidecar monitors TSDB — once a block is sealed (every 2h), it uploads to S3
3. Thanos Compactor periodically merges and downsamples blocks in S3
4. Grafana queries Thanos Query, which fans out to:
   - Sidecar → recent data (not yet in S3)
   - Store Gateway → historical data from S3

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Task](https://taskfile.dev/installation/)
- [AWS CLI](https://aws.amazon.com/cli/) (for S3 inspection)
- Linode API token
- AWS IAM credentials with S3 access

## Usage

```bash
# 1. Copy and fill in credentials
cp terraform.tfvars.example terraform.tfvars

# 2. Init and apply
terraform init
terraform apply

# 3. Set up kubeconfig
task kubeconfig
```

## Common Tasks

```bash
task open-grafana    # Open Grafana in browser
```
