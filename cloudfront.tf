# # CDN - Replica o site nas mais variadas regioes da aws, fazendo com que o 
# # usuario consiga acessar a aplicacao com a menor latencia possivel

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
 comment = local.domain # # original acesso, url principal
}

resource "aws_cloudfront_distribution" "this"{ # # distribuicao
  enabled = true
  is_ipv6_enabled = true
  comment = "Manage by Terraform"
  default_root_object = "index.html" # # objeto principal
  aliases = local.has_domain ? [local.domain] : []

  logging_config {
    bucket = module.logs.domain_name # # bucket de logs
    prefix = "cnd/"
    include_cookies = true
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET", "OPTIONS"] # # metodos permitidos 
    cached_methods = ["HEAD", "GET"]
    target_origin_id = local.regional_domain # # dominio regional 
    viewer_protocol_policy = "redirect-to-https" # # redirecionando para HTTPS
    min_ttl = 0 
    default_ttl = 3600 # # cache tempo
    max_ttl = 86400 # # cache tempo

    forwarded_values {
      query_string = false
      headers = [ "Origin" ] # # passar pra frente de onte esta vindo a request
      cookies{
        forward = "none"
      }
    }
  }

  origin { # origem
    domain_name = local.regional_domain 
    origin_id = local.regional_domain

    s3_origin_config{
      origin_acess_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_acess_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate"{  # # sem dominio personalizado (ele usa o do cloudfront)
    for_each = local.has_domain ? [] : [0]
    content {
      cloudfront_default_certificate = true
    }
  }

  dynamic "viewer_certificate" { # # com dominio personalizado 
    for_each = local.has_domain ? [0] : []
    content {
      acm_certificate_arn = aws_acm_certificate.this[0].arn
      ssl_support_method = "sni-only"
    }
  }

  tags = local.common_tags
}