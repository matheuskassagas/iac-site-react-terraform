data "aws_route53_zone" "this" { # # 
  count = local.has_domain ? 1 : 0
  name = "${local.domain}."
}

resource "aws_route53_record" "website" { # # aponta para o cloudfront
  count = local.has_domain ? 1 : 0

  name = local.domain 
  type = "A"
  zone_id = data.aws_route53_zone.this[0].zone_id # # [0] retorna uma lista acessa o primeiro elemento

  alias { # # onde passando a url do cloudfront
    evaluate_target_health = false
    name = aws_cloudfront_distribution.this.domain_name
    zone_id = aws_cloudfront_distribution.this.hosted_zone_id
  }
}

resource "aws_route53_record" "www" { # # aponta para bucket de redirect 
  count = local.has_domain ? 1 : 0

  name = "www.${local.domain}"
  type = "A"
  zone_id = data.aws_route53_zone.this[0].zone_id # # [0] retorna uma lista acessa o primeiro elemento

  alias { # # onde passando a url do cloudfront
    evaluate_target_health = false
    name = module.redirect.website_domain
    zone_id = module.redirect.hosted_zone_id
  }
}