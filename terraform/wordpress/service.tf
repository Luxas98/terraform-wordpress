resource "kubernetes_service" "wordpress" {
  provider = "kubernetes.wordpress"
  metadata {
    labels = {
      app = "wordpress"
    }
    namespace = kubernetes_namespace.wordpress.metadata[0].name
    name = "wordpress"
  }

  spec {
    type = "LoadBalancer"
    port {
      port = "80"
      target_port = "80"
      protocol = "TCP"
    }

    selector = {
      app = "wordpress"
    }

    load_balancer_ip = "${var.wordpress_ip}"
  }


}