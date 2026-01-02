resource "google_container_cluster" "gke" {
  name        = var.cluster_name
  location    = var.zone
  description = "GKE cluster for the data stack (Airflow, etc)."
  deletion_protection = false

  release_channel { channel = "REGULAR" }

  fleet {
    project = var.project_id
  }

  network    = google_compute_network.net.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Private cluster (nodes only have private IPs)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false       # set true if you want only private control plane
    master_ipv4_cidr_block  = "172.16.0.0/28"
    master_global_access_config {
      enabled = true
    }
  }

  maintenance_policy {
      # Allow maintenance (any kind) on Saturdays (all day)
    recurring_window {
      start_time = "2025-10-25T00:00:00Z"    # first Saturday
      end_time   = "2035-10-25T23:59:59Z"    # valid for 10 years
      recurrence = "FREQ=WEEKLY;BYDAY=SA"
    }
  }

  default_max_pods_per_node = 220

  remove_default_node_pool = true
  initial_node_count       = 1 # Required when removing default pool

  logging_config {
    enable_components = []
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "SCHEDULER",
      "CONTROLLER_MANAGER",
      "STORAGE",
      "HPA",
      "POD",
      "DAEMONSET",
      "DEPLOYMENT",
      "STATEFULSET",
      "CADVISOR",
      "JOBSET"
    ]
    managed_prometheus { 
      enabled = true 
      auto_monitoring_config {
        scope = "ALL"
      }
    }
  }

  vertical_pod_autoscaling { enabled = true }
  secret_manager_config    { enabled = true }

  addons_config {
    http_load_balancing                   { disabled = false }
    horizontal_pod_autoscaling            { disabled = false }
    gce_persistent_disk_csi_driver_config { enabled  = false }
    gcs_fuse_csi_driver_config            { enabled  = false }
    dns_cache_config                      { enabled  = false }
    config_connector_config               { enabled  = false }
    gke_backup_agent_config               { enabled  = true  }
    gcp_filestore_csi_driver_config       { enabled  = false }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Allocate Pod/Service ranges from subnetwork secondaries
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.subnet}-pods"
    services_secondary_range_name = "${var.subnet}-services"
  }

  cluster_autoscaling {
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }
}

resource "google_gke_backup_backup_plan" "weekly_cluster_backup" {
  name        = var.backup_plan_name_gke
  location    = var.region
  description = "Backup plan for the cluster: full backup every Sunday at 00:00 UTC; retain 30 days."
  cluster     = google_container_cluster.gke.id

  backup_schedule {
    cron_schedule = "0 0 * * 0" # Sunday 00:00 UTC
    paused        = false
  }

  retention_policy {
    backup_retain_days = 21
    locked             = false
  }

  backup_config {
    include_secrets     = true
    include_volume_data = true
    all_namespaces      = true
  }

  labels = { backup = "weekly", env = "dev" }
}
