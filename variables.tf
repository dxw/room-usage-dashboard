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

variable "ecs_private_subnets" {
  description = "ECS Private subnets"
  type        = "list"
  default     = []
}

variable "extra_private_subnets" {
  description = "Extra Private subnets"
  type        = "list"
  default     = []
}

variable "ecs_public_subnets" {
  description = "ECS Public subnets"
  type        = "list"
  default     = []
}

variable "extra_public_subnets" {
  description = "Extra Public subnets"
  type        = "list"
  default     = []
}
