# kubectl configuration command (use known vars)
output "kubectl_config_command" {
  description = "Command to CONNECT TO GKE"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --zone ${var.zone} --project ${var.project_id}"
}

output "static_ip" {
  description = "External Static IP for NGINX Load Balancer"
  value       = format("Static IP: %s", google_compute_address.external_ip_nginx_ingress_load_balancer_gke.address)
}
