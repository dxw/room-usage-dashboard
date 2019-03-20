data "aws_vpc" "dashboards_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dashboards-ecs-${var.environment}-ecs-vpc"]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster_name}"
}

data "aws_subnet" "ecs_private" {
  count = "${length(var.ecs_private_subnets)}"

  filter {
    name   = "cidr-block"
    values = ["${lookup(var.ecs_private_subnets[count.index], "cidr")}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.dashboards_vpc.id}"]
  }
}

data "aws_route_table" "private_subnet_route_table" {
  subnet_id = "${element(data.aws_subnet.ecs_private.*.id, 0)}"
}

data "aws_subnet" "ecs_public" {
  count = "${length(var.ecs_public_subnets)}"

  filter {
    name   = "cidr-block"
    values = ["${lookup(var.ecs_public_subnets[count.index], "cidr")}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.dashboards_vpc.id}"]
  }
}

data "aws_subnet" "extra_private" {
  count = "${length(var.extra_private_subnets)}"

  filter {
    name   = "cidr-block"
    values = ["${lookup(var.extra_private_subnets[count.index], "cidr")}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.dashboards_vpc.id}"]
  }
}

data "aws_subnet" "extra_public" {
  count = "${length(var.extra_public_subnets)}"

  filter {
    name   = "cidr-block"
    values = ["${lookup(var.extra_public_subnets[count.index], "cidr")}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.dashboards_vpc.id}"]
  }
}

data "aws_security_group" "ecs_security_group" {
  filter {
    name   = "tag:Name"
    values = ["ecs-sg-dashboards-${var.environment}"]
  }
}

data "aws_acm_certificate" "infrastructure_root_domain_wildcard" {
  domain      = "*.${var.environment}.${var.infrastructure_name}.${var.root_domain_zone}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "infrastructure_root_domain_zone" {
  name = "${var.environment}.${var.infrastructure_name}.${var.root_domain_zone}."
}

data "aws_route53_zone" "infrastructure_internal_domain_zone" {
  name   = "${var.environment}.${var.infrastructure_name}.${var.internal_domain_zone}."
  vpc_id = "${data.aws_vpc.dashboards_vpc.id}"
}

locals {
  ssm_parameters_command = [
    "wget",
    "https://github.com/Droplr/aws-env/raw/b215a696d96a5d651cf21a59c27132282d463473/bin/aws-env-linux-amd64",
    "-O",
    "aws-env",
    "&&",
    "chmod",
    "+x",
    "aws-env",
    "&&",
    "eval",
    "$(AWS_ENV_PATH=/${terraform.workspace}/$SSM_PATH_SUFFIX/ AWS_REGION=${var.region} ./aws-env)",
    "&&",
  ]
}
