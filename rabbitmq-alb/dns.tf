data "aws_route53_zone" "primary-private" {
  # private_zone = true
  name = var.domain_name
}

resource "aws_route53_record" "mgmt-internal" {
  zone_id         = data.aws_route53_zone.primary-private.zone_id
  name            = "${var.cluster_fqdn}.${var.domain_name}"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_lb.lb_internal.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbit-internal" {
  zone_id         = data.aws_route53_zone.primary-private.zone_id
  name            = "service-${var.cluster_fqdn}.${var.domain_name}"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_lb.lb_internal_net.dns_name]
  allow_overwrite = true
}

data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "mgmt" {
  zone_id         = data.aws_route53_zone.primary.zone_id
  name            = "${var.cluster_fqdn}.${var.domain_name}"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_lb.lb_internal.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbit" {
  zone_id         = data.aws_route53_zone.primary.zone_id
  name            = "service-${var.cluster_fqdn}.${var.domain_name}"
  type            = "CNAME"
  ttl             = "300"
  records         = [aws_lb.lb_internal_net.dns_name]
  allow_overwrite = true
}
