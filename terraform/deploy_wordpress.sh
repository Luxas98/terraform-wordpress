#!/usr/bin/env bash
PROJECT_ID=${PROJECT_ID:=$1}

cd cluster
terraform init
terraform apply -var="project_id=${PROJECT_ID}" -var="region=europe-west4" -var="zone=a"

CLUSTER_ENDPOINT=$(terraform output cluster-endpoint)
CLUSTER_CERT=$(terraform output cluster-cert)
WORDPRESS_IP=$(terraform output wordpress-ip)
INSTANCE_CONN_NAME=$(terraform output instance-connection-name)
SQL_PROXY_KEY=$(terraform output cloudsql-proxy-keys)
SQL_PASS=$(terraform output cloudsql-password)


cd ../wordpress/
terraform init
terraform apply -var="cloudsql_proxy_pass=${SQL_PASS}" -var="cloudsql_instance_creds=${SQL_PROXY_KEY}" -var="cluster_endpoint=${CLUSTER_ENDPOINT}" -var="cluster_cert=${CLUSTER_CERT}" -var="instance_connection_name=${INSTANCE_CONN_NAME}" -var="wordpress_ip=${WORDPRESS_IP}"