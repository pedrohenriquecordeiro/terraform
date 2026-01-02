resource "google_compute_network" "net" {
  name                    = var.network
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "VPC network for the data stack (GKE + VM)."
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.net.id
  private_ip_google_access = true
  description              = "Primary subnet for the data stack with secondary ranges for Pods and Services."

  secondary_ip_range {
    range_name    = "${var.subnet}-pods"
    ip_cidr_range = "10.0.16.0/20"
  }

  secondary_ip_range {
    range_name    = "${var.subnet}-services"
    ip_cidr_range = "10.0.32.0/20"
  }
}
