resource "kubernetes_namespace" "wordpress" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "wordpress"
  }
}