resource "aws_acm_certificate" "default" {
  count                     = "${var.enabled == "true" ? 1 : 0}"
  domain_name               = "${var.domain_name}"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.subject_alternative_names}"]
  tags                      = "${var.tags}"
}

data "aws_route53_zone" "default" {
  count        = "${var.enabled == "true" && var.proces_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0}"
  name         = "${var.domain_name}."
  private_zone = false
}

locals {
  domain_validation_options = "${var.enabled == "true" ? aws_acm_certificate.default.domain_validation_options[0] : map()}"
}

resource "aws_route53_record" "default" {
  count   = "${var.enabled == "true" && var.proces_domain_validation_options == "true" && var.validation_method == "DNS" ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${local.domain_validation_options["resource_record_name"]}"
  type    = "${local.domain_validation_options["resource_record_type"]}"
  ttl     = "${var.ttl}"
  records = ["${local.domain_validation_options["resource_record_value"]}"]
}
