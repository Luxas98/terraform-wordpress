resource "kubernetes_service" "wordpress" {
  provider = "kubernetes.wordpress"
  metadata {
    labels = {
      app = "wordpress"
    }

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