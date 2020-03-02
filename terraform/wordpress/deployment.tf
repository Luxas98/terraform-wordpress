resource "kubernetes_deployment" "wordpress" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "wordpress"
  }
  spec {
    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          name = "wordpress"
          image = "wordpress"
          env {
            name = "WORDPRESS_DB_HOST"
            value = "127.0.0.1:3306"
          }

          env {
            name = "WORDPRESS_DB_USER"
            value_from {
              secret_key_ref {
                name = "cloudsql-db-credentials"
                key = "username"
              }
            }
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name =  "cloudsql-db-credentials"
                key = "password"
              }
            }
          }

          port {
            container_port = 80
            name = "wordpress"
          }

          volume_mount {
            mount_path = "/var/www/html"
            name = "wordpress-persistent-storage"
          }
        }

        container {
          name = "cloudsql-proxy"
          image = "gcr.io/cloudsql-docker/gce-proxy:1.11"
          command = ["/cloud_sql_proxy",
                    "-instances=${var.instance_connection_name}=tcp:3306",
                    "-credential_file=/secrets/cloudsql/key.json"]

          security_context {
            run_as_user = 2
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/secrets/cloudsql"
            name = "cloudsql-instance-credentials"
            read_only = true
          }
        }

        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress-volumeclaim.metadata[0].name
          }
        }

        volume {
          name = "cloudsql-instance-credentials"
          secret {
            secret_name = "cloudsql-instance-credentials"
          }
        }
      }
    }
  }
}