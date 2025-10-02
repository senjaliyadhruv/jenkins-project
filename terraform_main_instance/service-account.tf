resource "google_service_account" "jumphost_sa" {
  account_id   = var.service_account_name
  display_name = "Jumphost Service Account"
}
