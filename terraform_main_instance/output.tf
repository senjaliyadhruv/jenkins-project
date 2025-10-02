output "region" {
  description = "Jumphost Server region"
  value       = var.region
}

output "jumphost_public_ip" {
  description = "Public IP address of the GCP jumphost"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
