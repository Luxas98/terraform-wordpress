provider "kubernetes" {
  alias = "wordpress"
  host = var.cluster_endpoint
  cluster_ca_certificate = var.cluster_cert
}