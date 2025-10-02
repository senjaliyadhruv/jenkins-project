terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0" # Adjust version if needed
    }
  }

  backend "gcs" {
    bucket = "cloudcore007"          # Replace with your GCS bucket name
    prefix = "eks/terraform.tfstate" # Similar to AWS S3 key
  }

  required_version = ">= 1.6.3"
}
