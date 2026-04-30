resource "linode_lke_cluster" "cluster" {
  label       = "cluster"
  k8s_version = "1.35"
  region      = "ap-northeast"
  tags        = ["prod"]

  pool {
    type  = "g6-standard-2"
    count = 4
  }
}

resource "local_file" "cluster_kubeconfig" {
  content  = base64decode(linode_lke_cluster.cluster.kubeconfig)
  filename = "${path.module}/kubeconfig.yaml"
}
