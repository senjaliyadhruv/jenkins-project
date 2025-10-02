variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "VPC name for our Jumphost server"
  type        = string
  default     = "jumphost-vpc"
}

variable "subnet_name" {
  description = "Subnet name for our Jumphost server"
  type        = string
  default     = "jumphost-subnet"
}

variable "firewall_name" {
  description = "Firewall rule name for our Jumphost server"
  type        = string
  default     = "jumphost-firewall"
}

variable "service_account_name" {
  description = "Service account for the Jumphost server"
  type        = string
  default     = "jumphost-sa"
}

variable "image" {
  description = "Image for the Compute Engine instance"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
}

variable "machine_type" {
  description = "Machine type for the Compute Engine instance"
  type        = string
  default     = "e2-medium"
}

variable "username" {
  description = "SSH username for the instance"
  type        = string
  default     = "dhruv"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "instance_name" {
  description = "Compute Engine instance name"
  type        = string
  default     = "jumphost-server"
}

variable "instance_tag" {
  description = "Tag for the instance (used in firewall rules)"
  type        = string
  default     = "jumphost"
}
