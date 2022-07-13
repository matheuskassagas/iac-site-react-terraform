data "aws_route53_zone" "this" { # # 
  count = local.has_domain ? 1 : 0 # # cria apenas se passar um domain
  name = "${local.domain}." 
}

resource "aws_route53_record" "website" { # # aponta para o cloudfront
  count = local.has_domain ? 1 : 0

  name = local.domain 
  type = "A"
  zone_id = data.aws_route53_zone.this[0].zone_id # # [0] retorna uma lista / acessa o primeiro elemento

  alias { # # onde passa a url do cloudfront
    evaluate_target_health = false
    name = aws_cloudfront_distribution.this.domain_name # # CDN nome da distribuicao
    zone_id = aws_cloudfront_distribution.this.hosted_zone_id # # CDN zona da distribuicao
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

resource "aws_route53_record" "cert_validation" { # # referente ao certificado ACM
  for_each = { # # retorno do acm
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.aws_route53_zone.this[0].zone_id
}