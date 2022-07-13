resource "aws_acm_certificate" "cert" { # # so cria se o domain estiver setado 
  count = local.has_domain ? 1 : 0

  provider = aws.eu-central-1

  domain_name = local.domain 
  validation_method = "DNS"
  subject_alternative_names = [ "*.${local.domain}" ] # # subdominios
}

resource "aws_acm_certificate_validation" "this" { # # validacao 
  count = local.has_domain ? 1 : 0

  provider = aws.eu-central-1 

  certificate_arn = aws_acm_certificate.this[0].arn # # certificado lista
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# # necessario criar um record no route53