# VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

# Subnet (Public)
resource "google_compute_subnetwork" "public_subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall (like AWS Security Group)
resource "google_compute_firewall" "firewall" {
  name    = var.firewall_name
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "9000", "9090"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  target_tags = [var.instance_tag]
}

# Default Egress (like AWS SG outbound rule)
resource "google_compute_firewall" "egress_all" {
  name    = "${var.firewall_name}-egress"
  network = google_compute_network.vpc.id

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]

  target_tags = [var.instance_tag]
}
