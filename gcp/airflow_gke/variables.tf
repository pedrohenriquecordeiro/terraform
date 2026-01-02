# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "dw-corp-dev"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-c"
}

variable "service_account" {
  description = "Service account email to use for resources"
  type        = string
  default     = "sa-data-stack@dw-corp-dev.iam.gserviceaccount.com"
}

# ==============================================================================
# NETWORK CONFIGURATION
# ==============================================================================
variable "network" {
  description = "Name of the VPC network"
  type        = string
  default     = "vpc-data-stack"
}

variable "subnet" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-data-stack"
}

variable "subnet_cidr" {
  description = "CIDR for the primary subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# Cloud NAT / Router
variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
  default     = "router-vpc-data-stack"
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
  default     = "nat-vpc-data-stack"
}

# ==============================================================================
# STATIC IP ADDRESSES
# ==============================================================================
# Internal Static IP (Compute Engine - NFS Server)
variable "internal_ip_name_instance_nfs_server" {
  description = "Name of the reserved internal IP for the VM"
  type        = string
  default     = "instance-nfs-server-internal-ip"
}

variable "internal_ip_address_instance_nfs_server" {
  description = "Reserved internal IP for the VM"
  type        = string
  default     = "10.0.0.165"
}

# External Static IP (GKE Cluster - Data Stack)
variable "external_ip_name_gke_cluster_data_stack" {
  description = "Name of the static external IP for NAT"
  type        = string
  default     = "gke-cluster-data-stack-external-ip"
}

# EXISTING External Static IP (GKE Cluster - Data Stack)
variable "existing_external_ip_name_gke_cluster_data_stack" {
  description = "Name of the existing static external IP for NAT"
  type        = string
  default     = "external-static-ip-address-vpc-gke-apache-airflow-2"
}

variable "external_ip_name_nginx_ingress_load_balancer_gke" {
  description = "Specific external IP to reserve for NGINX Ingress"
  type        = string
  default     = "external-ip-nginx-ingress-load-balancer-gke"
}

variable "external_ip_address_gke_cluster_data_stack" {
  description = "Specific external IP to reserve for NGINX Ingress"
  type        = string
  default     = "34.135.120.200"
}

# ==============================================================================
# GKE CLUSTER CONFIGURATION
# ==============================================================================
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "cluster-data-stack"
}

# Core Node Pool
variable "core_node_pool_name" {
  description = "Name of the core node pool"
  type        = string
  default     = "core-pool"
}

variable "core_node_pool_machine_type" {
  description = "Machine type for the core node pool"
  type        = string
  default     = "c2-standard-4" # "c2d-highcpu-8"
}

# Work Node Pool
variable "work_node_pool_name" {
  description = "Name of the work node pool"
  type        = string
  default     = "work-pool"
}

variable "work_node_pool_machine_type" {
  description = "Machine type for the work node pool"
  type        = string
  default     = "c2d-highcpu-8" # "c2d-highcpu-8"
}

# Test Node Pool
variable "test_node_pool_name" {
  description = "Name of the test node pool"
  type        = string
  default     = "test-node-pool"
}

variable "test_node_pool_machine_type" {
  description = "Machine type for the test node pool"
  type        = string
  default     = "c2d-highcpu-8" # "c2d-highcpu-8"
}

# ==============================================================================
# COMPUTE ENGINE CONFIGURATION
# ==============================================================================
variable "instance_name" {
  description = "Compute Engine instance name"
  type        = string
  default     = "instance-nfs-server"
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  default     = "e2-small"
}

variable "instance_tags" {
  description = "Network tags for the VM"
  type        = list(string)
  default     = ["nfs", "gke"]
}

# Disk Configuration
variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 45
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-ssd"
}

# Image Configuration
variable "image_family" {
  description = "Image family for the boot disk"
  type        = string
  default     = "ubuntu-minimal-2204-lts"
}

variable "image_project" {
  description = "Project providing the image family"
  type        = string
  default     = "ubuntu-os-cloud"
}

# Service Account Scopes
variable "scopes" {
  description = "OAuth scopes for the instance's service account"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
}

# ==============================================================================
# BACKUP AND SNAPSHOT CONFIGURATION
# ==============================================================================
variable "resource_policy_name_snapshot_disk" {
  description = "Name of the resource policy for disk snapshots"
  type        = string
  default     = "resource-policy-boot-weekly-sun"
}

variable "backup_plan_name_gke" {
  description = "Name of the backup plan for GKE"
  type        = string
  default     = "backup-plan-weekly-sun"
}
