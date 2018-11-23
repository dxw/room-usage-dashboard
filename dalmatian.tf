provider "aws" {
  alias  = "main"
  region = "${var.region}"
}

data "aws_caller_identity" "current" {
  provider = "aws.main"
}

locals {
  account_id = "${var.account_id == "" ? data.aws_caller_identity.current.account_id : var.account_id}"
}

provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn     = "arn:aws:iam::${local.account_id}:role/${var.dalmatian_role}"
    session_name = "dalmatian"
  }
}

terraform {
  backend "s3" {
    bucket  = "terraform-state.dalmatian.dxw.net"
    key     = "dalmatian/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}
