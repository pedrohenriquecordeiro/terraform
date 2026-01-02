resource "google_compute_address" "internal" {
  name         = var.internal_ip_name_instance_nfs_server
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet.self_link
  address      = var.internal_ip_address_instance_nfs_server
  description  = "Reserved internal IP for the NFS instance."
}

# # Create a NEW regional static external IP
# resource "google_compute_address" "external" {
#   name         = var.external_ip_name_gke_cluster_data_stack
#   region       = var.region
#   address_type = "EXTERNAL"
#   description  = "Static external IP used by Cloud NAT for egress."
#   # address    = var.external_ip_address_gke_cluster_data_stack  # let GCP allocate unless you own a specific IP
# }

# Ip used to assign to the NGINX Ingress LoadBalancer (make UI accessible)
resource "google_compute_address" "external_ip_nginx_ingress_load_balancer_gke" {
   name         = var.external_ip_name_nginx_ingress_load_balancer_gke
   region       = var.region
   address_type = "EXTERNAL"
   network_tier = "PREMIUM"
   description  = "Static external IP used by NGINX Ingress LoadBalancer."
   # let GCP allocate unless you own a specific IP
 }

# Reference an EXISTING regional static external IP by name
# Ip used to assign to the NAT gateway (RDS databases have this IP in their authorized networks whitelist)
data "google_compute_address" "existing_external" {
  name   = var.existing_external_ip_name_gke_cluster_data_stack  # must already exist
  region = var.region                                            # must match NAT/router region
}
