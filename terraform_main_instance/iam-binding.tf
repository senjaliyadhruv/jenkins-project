# This gives the service account Owner-like permissions (equivalent to AdministratorAccess in AWS)
# ⚠️ Just for testing – in production, assign only the needed roles
resource "google_project_iam_member" "jumphost_sa_admin" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.jumphost_sa.email}"
}
