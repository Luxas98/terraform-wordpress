resource "kubernetes_persistent_volume_claim" "wordpress-volumeclaim" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "wordpress-volumeclaim"
    namespace = kubernetes_namespace.wordpress.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
}


