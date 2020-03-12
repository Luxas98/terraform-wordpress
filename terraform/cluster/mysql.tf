resource "google_project_service" "cloudsql-service" {
 project = "${var.project_id}"
 service = "sql-component.googleapis.com"
 disable_dependent_services = false
 disable_on_destroy = false
}


resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "wordpress" {
  provider = "google-beta"
  name             = "wordpress-instance-1-${random_id.db_name_suffix.hex}"
  database_version = "MYSQL_5_6"
  project = "${var.project_id}"
  # First-generation instance regions are not the conventional
  # Google Compute Engine regions. See argument reference below.
  region = "${var.region}"

  settings {
    tier = "db-f1-micro"
  }

}

resource "google_sql_user" "users" {
  project = "${var.project_id}"
  name     = "wordpress"
  instance = google_sql_database_instance.wordpress.name
  host     = "%"
  password = "9b423f37c9994e5fb6608ddc"
}


resource "google_service_account" "cloudsql-proxy" {
  project = "${var.project_id}"
  account_id = "cloudsql-proxy"
  display_name = "cloudsql-proxy"
}

resource "google_service_account_key" "cloudsql-proxy-keys" {
  service_account_id = google_service_account.cloudsql-proxy.name
}


resource "google_project_iam_binding" "cloudsql-proxy-binding" {
  project = "${var.project_id}"
  members = [
    "serviceAccount:${google_service_account.cloudsql-proxy.email}"
  ]
  role = "roles/cloudsql.client"
}

