data "aws_route53_zone" "vault_zone" {

  name = var.route_53_domain

}

resource "aws_route53_record" "vault_dns" {

  zone_id = data.aws_route53_zone.vault_zone.id
  name    = "vault"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.vault.public_ip]

}