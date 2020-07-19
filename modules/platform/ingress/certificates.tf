resource "aws_acm_certificate" "cluster_cert" {
  domain_name       = aws_route53_record.alb_record.name
  validation_method = "DNS"
}

resource "aws_route53_record" "validation" {
  name    = aws_acm_certificate.cluster_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cluster_cert.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.public_domain_zone.zone_id
  records = [aws_acm_certificate.cluster_cert.domain_validation_options[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "cluster_cert" {
  certificate_arn = aws_acm_certificate.cluster_cert.arn
  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
  ]
}
