resource "kubernetes_persistent_volume_claim" "wordpress-volumeclaim" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "wordpress-volumeclaim"
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


