resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
 comment = local.domain 
}

resource "aws_cloudfront_distribution" "this"{
  enabled = true
  is_ipv6_enabled = true
  comment = "Manage by Terraform"
  default_root_object = "index.html"

  logging_config {
    bucket = module.logs.domain_name
    prefix = "cnd/"
    include_cookies = true
  }

  default_cache_behavior {
    allowed_methods = ["GET", "OPTIONS", "HEAD"]
    cached_methods = ["GET"]
    target_origin_id = local.regional_domain
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      query_string = false
      headers = [ "Origin" ]
      cookies{
        forward = "none"
      }
    }
  }

  origin {
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

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.common_tags
}