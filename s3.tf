data "template_file" "s3-public-policy" {
  template = file("policy.json")
  vars { bucket_name = local.domain }
}

module "logs" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"
  name = "${local.domain}-logs"
  acl = "log-delivery-write"
  force_destroy = !local.has_domain
}

module "website" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"
  name = ""
  force_destroy = !local.has_domain
}

module "redirect" {
  source = "github.com/chgasparoto/terraform-s3-object-notification"
  name = "www.${local.domain}"
  acl = "public_read"
  force_destroy = !local.has_domain
  
  website = {
    redirect_all_requests_to = local.domain ? var.domain : module.website.website
  }
}