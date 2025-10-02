terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }

  backend "gcs" {
    bucket = "cloudcore007" # Create this GCS bucket first
    prefix = "terraform/state"
  }

  required_version = ">= 1.6.3"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
