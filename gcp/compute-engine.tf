# Resolve a stable Ubuntu LTS image
data "google_compute_image" "os" {
  family      = var.image_family
  project     = var.image_project
}

# Weekly snapshot schedule for the boot disk (every Sunday at 00:00 UTC)
resource "google_compute_resource_policy" "boot_weekly_snapshots" {
  name        = var.resource_policy_name_snapshot_disk
  region      = var.region
  description = "Snapshot schedule for the VM boot disk: every Sunday at 00:00 UTC; retain for 30 days."

  snapshot_schedule_policy {
    schedule {
      weekly_schedule {
        day_of_weeks {
          day        = "SUNDAY"
          start_time = "00:00" # 00:00 UTC
        }
      }
    }

    retention_policy {
      max_retention_days    = 30
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      labels = {
        backup = "weekly"
        env    = "dev"
      }
      guest_flush = false
    }
  }
}

# Boot disk as a managed resource (so we can attach the backup policy)
resource "google_compute_disk" "boot" {
  name        = var.instance_name
  type        = var.disk_type
  zone        = var.zone
  size        = var.disk_size_gb
  image       = data.google_compute_image.os.self_link
  description = "Boot disk for the NFS VM with weekly snapshot policy."
}

resource "google_compute_disk_resource_policy_attachment" "boot_backup_attachment" {
  name = google_compute_resource_policy.boot_weekly_snapshots.name
  disk = google_compute_disk.boot.name
  zone = var.zone
}


resource "google_compute_instance" "instance_nfs_server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  description  = "NFS server VM for GKE workloads; private NIC with reserved internal IP and weekly disk backups."

  allow_stopping_for_update = true

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  # Attach the pre-created boot disk (kept when VM is deleted)
  boot_disk {
    auto_delete = false
    source      = google_compute_disk.boot.self_link
  }

  # Internal-only NIC (no external IP)
  network_interface {
    network     = google_compute_network.net.id
    subnetwork  = google_compute_subnetwork.subnet.self_link
    network_ip  = google_compute_address.internal.address
  }

  service_account {
    email  = var.service_account
    scopes = var.scopes
  }

  deletion_protection = false

  metadata_startup_script = <<-EOF
    #!/bin/bash
    
    sudo apt-get update
    sudo apt-get install -y nfs-kernel-server nfs-common

    sudo mkdir -p /exports/postgres
    sudo mkdir -p /exports/airflow-logs
    sudo mkdir -p /exports/prometheus

    sudo chown -R nobody:nogroup /exports/postgres /exports/airflow-logs /exports/prometheus
    sudo chmod -R 777 /exports/postgres /exports/airflow-logs /exports/prometheus

    ## 10.0.0.0/24 => it is the CIDR notation for the VPC network range (variable "subnet_cidr" in terraform)
    echo "/exports/postgres 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports      
    echo "/exports/airflow-logs 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
    echo "/exports/prometheus 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

    sudo exportfs -rav

    sudo systemctl restart nfs-kernel-server
    sudo systemctl status nfs-kernel-server
  
  EOF

  tags = var.instance_tags
}
