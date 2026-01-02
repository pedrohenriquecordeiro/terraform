# Discover the subnet (primary + secondaries) to compute source CIDRs
data "google_compute_subnetwork" "gke_subnet" {
  name   = google_compute_subnetwork.subnet.name
  region = var.region
}

locals {
  # Your Pods secondary range is created in network.tf as "${var.subnet}-pods"
  pods_secondary_range_name = "${var.subnet}-pods"

  pods_cidr = one([
    for r in data.google_compute_subnetwork.gke_subnet.secondary_ip_range :
    r.ip_cidr_range if r.range_name == local.pods_secondary_range_name
  ])

  # Source ranges: node CIDR (primary subnet) + pods CIDR
  nfs_allowed_sources = distinct([
    data.google_compute_subnetwork.gke_subnet.ip_cidr_range,
    local.pods_cidr
  ])
}

resource "google_compute_firewall" "allow_nfs_rpc_from_gke" {
  name        = "allow-nfs-rpc-from-gke"
  network     = google_compute_network.net.name
  description = "Allow NFS (2049) and RPC bind (111) TCP/UDP from GKE nodes and pods to NFS VM."

  direction = "INGRESS"
  priority  = 1000

  # GKE nodes (primary) + Pods (secondary)
  source_ranges = local.nfs_allowed_sources

  # Apply to your NFS VM (it already uses tags = var.instance_tags in compute_engine.tf)
  target_tags = var.instance_tags

  allow {
    protocol = "tcp"
    ports    = ["111", "2049"]
  }
  allow {
    protocol = "udp"
    ports    = ["111", "2049"]
  }
}
