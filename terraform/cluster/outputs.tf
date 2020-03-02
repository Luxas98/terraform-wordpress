output "primary_cluster_name" {
 value = "${google_container_cluster.primary.name}"
}

output "service_pool_id" {
  value = "${google_container_node_pool.service-pool.id}"
}

output "cluster_admin_access_token" {
  value = "${data.kubernetes_secret.cluster-admin-token.data["token"]}"
  sensitive = true
}

output "cluster_admin_ca_cert" {
  value = "${data.kubernetes_secret.cluster-admin-token.data["ca.crt"]}"
  sensitive = true
}

output "wordpress-ip" {
  value = google_compute_address.wordpress-ip.address
}

output "cluster-endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster-cert" {
  value = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

output "instance-connection-name" {
  value = google_sql_database_instance.wordpress.connection_name
}

output "cloudsql-proxy-keys" {
  value = base64decode(google_service_account_key.cloudsql-proxy-keys.private_key)
}

output "cloudsql-password" {
  value = google_sql_user.users.password
}