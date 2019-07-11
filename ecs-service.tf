resource "aws_cloudwatch_log_group" "app_service_logs" {
  name              = "${terraform.workspace}-app"
  retention_in_days = 90
}

data "template_file" "app_container_definition" {
  template = "${file("./container_definitions/app.json.tpl")}"

  vars {
    image          = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${terraform.workspace}-app"
    container_name = "${terraform.workspace}-app"
    container_port = "9292"
    log_group      = "${aws_cloudwatch_log_group.app_service_logs.name}"
    log_region     = "${var.region}"
    entrypoint     = "${jsonencode(list("/bin/bash","-c",join(" ",concat(local.ssm_parameters_command, local.app_container_entrypoint, local.app_container_command))))}"
  }
}

resource "aws_iam_role" "app_ecs_execution_role" {
  name               = "app_${terraform.workspace}_ecs_task_execution_role"
  assume_role_policy = "${file("./policies/ecs_task_execution_role.json.tpl")}"
}

resource "aws_iam_role_policy" "app_ecs_execution_role_policy" {
  name   = "app_${terraform.workspace}_ecs_execution_role_policy"
  policy = "${file("./policies/app_ecs_task_execution_role_policy.json.tpl")}"
  role   = "${aws_iam_role.app_ecs_execution_role.id}"
}

resource "aws_iam_role" "app_task_role" {
  name               = "app_${terraform.workspace}_task_role"
  assume_role_policy = "${file("./policies/app_task_role.json.tpl")}"
}

data "template_file" "app_task_role" {
  template = "${file("./policies/app_task_role_policy.json.tpl")}"

  vars {
    ssm_resource = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${terraform.workspace}/*"
    kms_key      = "${aws_kms_key.app_ssm.arn}"
  }
}

resource "aws_iam_role_policy" "app_task_role_policy" {
  name   = "app_${terraform.workspace}_task_role_policy"
  policy = "${data.template_file.app_task_role.rendered}"
  role   = "${aws_iam_role.app_task_role.id}"
}

module "app-service" {
  source = "./vendor/terraform_modules/terraform-aws-ecs-service"

  environment = "dxw"

  service_name          = "app-${var.environment}"
  service_desired_count = 2

  vpc_id   = "${data.aws_vpc.dashboards_vpc.id}"
  vpc_cidr = "${data.aws_vpc.dashboards_vpc.cidr_block}"

  lb_subnetids = [
    "${element(data.aws_subnet.extra_public.*.id, 0)}",
    "${element(data.aws_subnet.extra_public.*.id, 1)}",
    "${element(data.aws_subnet.extra_public.*.id, 2)}",
  ]

  lb_internal = false

  ecs_cluster_id = "${var.cluster_name}"

  task_definition   = "${data.template_file.app_container_definition.rendered}"
  task_network_mode = "bridge"
  task_memory       = "512"

  service_launch_type = "EC2"

  task_role_arn = "${aws_iam_role.app_task_role.arn}"

  public_alb_whitelist = [
    "37.157.36.10/32",
    "54.76.254.148/32",
  ]

  lb_target_group = {
    target_type    = "instance"
    container_name = "${terraform.workspace}-app"
    container_port = "9292"
  }

  lb_health_check = [{
    path                = "/check"
    protocol            = "HTTP"
    matcher             = "200,301"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
  }]

  lb_listener = {
    port            = 443
    protocol        = "HTTPS"
    certificate_arn = "${data.aws_acm_certificate.infrastructure_root_domain_wildcard.arn}"
    ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }

  lb_security_group_ids = ["${data.aws_security_group.ecs_alb_security_group.id}"]
}
