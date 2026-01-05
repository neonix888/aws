# Custom Domain Setup (Optional)

> **Status**: SHELVED - Future enhancement
>
> This is optional. The project works out-of-the-box with CloudFront URLs.
> Custom domain setup is specific to your domain and DNS provider.

---

## Default Behavior (No Custom Domain)

When you deploy this project, you get:
- **Website**: `https://<random>.cloudfront.net`
- **API**: `https://<random>.execute-api.<region>.amazonaws.com`

This works for anyone who clones the repo. No DNS configuration needed.

---

## Custom Domain Options

If you want to use your own domain (e.g., `resume.example.com`), there are several approaches:

### Option A: Point Domain to CloudFront (Recommended)

**Requirements**:
1. ACM Certificate for your domain (must be in `us-east-1` for CloudFront)
2. CloudFront alternate domain name (CNAME)
3. DNS record pointing to CloudFront

**Steps**:
```bash
# 1. Request ACM certificate (us-east-1 required for CloudFront)
aws acm request-certificate \
  --domain-name resume.example.com \
  --validation-method DNS \
  --region us-east-1

# 2. Validate certificate via DNS (add CNAME record provided by ACM)

# 3. Update CloudFront distribution with:
#    - Alternate domain name: resume.example.com
#    - SSL certificate: ACM certificate ARN

# 4. Update DNS: CNAME resume.example.com → <dist>.cloudfront.net
```

**Terraform Changes** (to add to cloudfront module):
```hcl
variable "domain_name" {
  description = "Custom domain name (optional)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

# In aws_cloudfront_distribution:
aliases = var.domain_name != "" ? [var.domain_name] : []

viewer_certificate {
  acm_certificate_arn      = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
  ssl_support_method       = var.acm_certificate_arn != "" ? "sni-only" : null
  cloudfront_default_certificate = var.acm_certificate_arn == ""
}
```

### Option B: Subdomain Approach

Use your main domain as a portal, subdomains for projects:
```
projects.example.com  → Portal/index page
resume.example.com    → CloudFront (this project)
backup.example.com    → CloudFront (project 2)
```

### Option C: Reverse Proxy (Not Recommended)

Proxy through nginx/Apache to CloudFront.
- Adds latency
- Complicates SSL
- Defeats purpose of CDN

---

## Implementation Priority

This is a **nice-to-have** enhancement. The project is fully functional without it.

**When to implement**:
- After all 10 projects are deployed
- When preparing final portfolio presentation
- If you need a memorable URL for sharing

---

## Related Files

If implementing custom domain, these files would need updates:
- `terraform/modules/cloudfront/main.tf` - Add aliases and certificate
- `terraform/modules/cloudfront/variables.tf` - Add domain variables
- `terraform/variables.tf` - Add root-level domain config
- DNS records at your domain registrar

---

## Notes

- CloudFront requires ACM certificates in `us-east-1` region
- DNS propagation can take up to 48 hours
- Consider using Route53 for easier AWS integration
