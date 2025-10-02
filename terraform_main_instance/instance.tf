resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = 30
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.id
    access_config {}
  }

  service_account {
    email  = google_service_account.jumphost_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("./install-tools.sh")

  tags = [var.instance_tag]
}
