variable "region" {
  description = "AWS Region"
}

variable "infrastructure_name" {
  description = "Infrastructure name"
}

variable "dalmatian_role" {
  description = "Dalmatian Role"
}

variable "account_id" {
  description = "AWS Account ID"
}

variable "environment" {
  description = "Environment"
}

variable "root_domain_zone" {
  description = "Root domain zone"
}

variable "internal_domain_zone" {
  description = "Internal domain zone"
}

variable "track_revision" {
  description = "Git branch to track"
}

variable "app_github_token" {
  description = "App GitHub Token"
}

variable "cluster_name" {
  description = "Cluster Name"
}
