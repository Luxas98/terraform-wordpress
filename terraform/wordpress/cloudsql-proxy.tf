resource "kubernetes_secret" "cloudsql-db-credentials" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "cloudsql-db-credentials"
    namespace = kubernetes_namespace.wordpress.metadata[0].name
  }

  data = {
    username = "wordpress"
    password = var.cloudsql_proxy_pass
  }
}

resource "kubernetes_secret" "cloudsql-instance-credentials" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "cloudsql-instance-credentials"
    namespace = kubernetes_namespace.wordpress.metadata[0].name
  }

  data = {
    "key.json" = var.cloudsql_instance_creds
  }
}