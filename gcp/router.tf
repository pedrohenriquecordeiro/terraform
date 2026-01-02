resource "google_compute_router" "cloud_router" {
  name        = var.router_name
  region      = var.region
  network     = google_compute_network.net.id
  description = "Cloud Router for NAT to allow private nodes/VMs to reach the Internet."
}
