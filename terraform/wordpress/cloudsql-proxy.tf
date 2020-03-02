resource "kubernetes_secret" "cloudsql-db-credentials" {
  provider = "kubernetes.wordpress"
  metadata {
    name = "cloudsql-db-credentials"
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
  }

  data = {
    "key.json" = var.cloudsql_instance_creds
  }
}