resource "google_container_node_pool" "core_node_pool" {
  name        = var.core_node_pool_name
  cluster     = google_container_cluster.gke.name
  location    = var.zone

  initial_node_count = 1
  max_pods_per_node  = 220

  node_config {
    machine_type    = var.core_node_pool_machine_type
    disk_size_gb    = 100
    image_type      = "COS_CONTAINERD"
    disk_type       = "pd-balanced"
    spot            = false
    service_account = var.service_account

    # Kubernetes node labels
    labels = {
      node-pool-name = var.core_node_pool_name
    }

    resource_labels = {
      node-pool-name = var.core_node_pool_name
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  autoscaling {
    min_node_count  = 1
    max_node_count  = 2
    location_policy = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  # Nodes are private because the cluster is private; no per-pool setting exists.
  # Secondary ranges are created on the subnet and assigned via cluster ip_allocation_policy.

  placement_policy { type = "COMPACT" }
}

resource "google_container_node_pool" "work_node_pool" {
  name        = var.work_node_pool_name
  cluster     = google_container_cluster.gke.name
  location    = var.zone

  initial_node_count = 1
  max_pods_per_node  = 220

  node_config {
    machine_type    = var.work_node_pool_machine_type
    disk_size_gb    = 100
    image_type      = "COS_CONTAINERD"
    disk_type       = "pd-balanced"
    spot            = false
    service_account = var.service_account

    # Kubernetes node labels
    labels = {
      node-pool-name = var.work_node_pool_name
    }


    resource_labels = {
      node-pool-name = var.work_node_pool_name
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  autoscaling {
    min_node_count  = 0
    max_node_count  = 5
    location_policy = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  # Nodes inherit private networking from the cluster; secondary ranges handled via cluster ip_allocation_policy.

  placement_policy { type = "COMPACT" }
}


resource "google_container_node_pool" "dev_node_pool" {
  name        = var.test_node_pool_name
  cluster     = google_container_cluster.gke.name
  location    = var.zone

  initial_node_count = 1
  max_pods_per_node  = 220

  node_config {
    machine_type    = var.test_node_pool_machine_type
    disk_size_gb    = 100
    image_type      = "COS_CONTAINERD"
    disk_type       = "pd-balanced"
    spot            = true
    service_account = var.service_account

    # Kubernetes node labels
    labels = {
      node-pool-name = var.test_node_pool_name
    }


    resource_labels = {
      node-pool-name = var.test_node_pool_name
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  autoscaling {
    min_node_count  = 0
    max_node_count  = 1
    location_policy = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  # Nodes inherit private networking from the cluster; secondary ranges handled via cluster ip_allocation_policy.

  placement_policy { type = "COMPACT" }
}
