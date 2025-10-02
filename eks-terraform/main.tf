provider "google" {
  project = "polar-arbor-464909-g3"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "storage-api.googleapis.com",
  ])

  project = "polar-arbor-464909-g3"
  service = each.key

  disable_on_destroy = false
}

# -------------------------------
# Use Existing VPC
# -------------------------------
data "google_compute_network" "vpc" {
  name = "jumphost-vpc"
}

# -------------------------------
# Create NEW Subnet for GKE with Secondary Ranges
# -------------------------------
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = data.google_compute_network.vpc.id
  region        = "us-central1"

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# -------------------------------
# IAM Service Account for GKE
# -------------------------------
resource "google_service_account" "gke_sa" {
  account_id   = "gke-cluster-sa"
  display_name = "GKE Cluster Service Account"
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/container.nodeServiceAccount",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
  ])
  project = "polar-arbor-464909-g3"
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# -------------------------------
# Firewall Rules
# -------------------------------
resource "google_compute_firewall" "gke_ssh" {
  name    = "gke-allow-ssh"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node"]
}

resource "google_compute_firewall" "gke_internal" {
  name    = "gke-allow-internal"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# -------------------------------
# GKE Zonal Cluster (reduced quota usage)
# -------------------------------
resource "google_container_cluster" "gke_cluster" {
  name       = "project-gke-cluster"
  location   = "us-central1-a" # Changed to zonal
  network    = data.google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }

  workload_identity_config {
    workload_pool = "polar-arbor-464909-g3.svc.id.goog"
  }

  depends_on = [
    google_project_iam_member.gke_sa_roles,
    google_compute_subnetwork.gke_subnet
  ]
}

# -------------------------------
# GKE Node Pool (optimized for quota)
# -------------------------------
resource "google_container_node_pool" "node_pool" {
  name     = "project-node-pool"
  cluster  = google_container_cluster.gke_cluster.name
  location = google_container_cluster.gke_cluster.location

  initial_node_count = 1

  node_config {
    machine_type = "e2-small"    # Smaller machine type
    disk_size_gb = 20            # Reduced disk size
    disk_type    = "pd-standard" # Standard persistent disk (not SSD)

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = google_service_account.gke_sa.email
    tags            = ["gke-node"]

    labels = {
      env = "dev"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Explicitly disable boot disk encryption to avoid SSD requirements
    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  depends_on = [
    google_container_cluster.gke_cluster
  ]
}

# -------------------------------
# Outputs
# -------------------------------
output "cluster_name" {
  value       = google_container_cluster.gke_cluster.name
  description = "GKE Cluster Name"
}

output "cluster_endpoint" {
  value       = google_container_cluster.gke_cluster.endpoint
  description = "GKE Cluster Endpoint"
  sensitive   = true
}

output "cluster_location" {
  value       = google_container_cluster.gke_cluster.location
  description = "GKE Cluster Location"
}

output "get_credentials_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster.name} --zone=${google_container_cluster.gke_cluster.location} --project=polar-arbor-464909-g3"
  description = "Command to configure kubectl"
}
