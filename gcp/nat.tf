resource "google_compute_router_nat" "cloud_nat" {
  name        = var.nat_name
  router      = google_compute_router.cloud_router.name
  region      = var.region

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [data.google_compute_address.existing_external.self_link] # use an existing static IP
                         # [google_compute_address.external.self_link]                 create new static IP

  enable_dynamic_port_allocation      = true
  min_ports_per_vm                    = 32
  max_ports_per_vm                    = 65536
  enable_endpoint_independent_mapping = false

  udp_idle_timeout_sec             = 30
  tcp_established_idle_timeout_sec = 1200
  tcp_transitory_idle_timeout_sec  = 30
  icmp_idle_timeout_sec            = 30
  tcp_time_wait_timeout_sec        = 120

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}
