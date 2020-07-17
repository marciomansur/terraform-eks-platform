data "aws_route53_zone" "public_domain_zone" {
  name = var.public_domain
}

resource "aws_route53_zone" "env_domain" {
  name = "${var.env}.${var.public_domain}"

  tags = local.tags
}

resource "aws_route53_record" "env_to_hostedzone" {
  name    = "${var.env}.${var.public_domain}"
  zone_id = data.aws_route53_zone.public_domain_zone.zone_id
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.env_domain.name_servers.0,
    aws_route53_zone.env_domain.name_servers.1,
    aws_route53_zone.env_domain.name_servers.2,
    aws_route53_zone.env_domain.name_servers.3
  ]
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.public_domain_zone.zone_id
  name    = "*.${aws_route53_record.env_to_hostedzone.name}"
  type    = "A"

  alias {
    name                   = aws_lb.cluster_alb.dns_name
    zone_id                = aws_lb.cluster_alb.zone_id
    evaluate_target_health = false
  }
}
