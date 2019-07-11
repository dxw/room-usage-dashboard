resource "aws_route53_record" "room-usage" {
  zone_id = "${data.aws_route53_zone.infrastructure_root_domain_zone.zone_id}"
  name    = "room-usage-dashboard.${var.environment}.${var.infrastructure_name}.${var.root_domain_zone}."
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "${module.app-service.lb_dns_name}",
  ]
}
