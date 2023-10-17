data "cloudflare_zone" "main" {
  name = local.cloudflare_zone
}

resource "cloudflare_record" "main" {
  zone_id = data.cloudflare_zone.main.id
  name    = local.main_domain
  type    = "A"
  value   = aws_instance.app.public_ip
}