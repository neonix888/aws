output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.static_site.arn
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.static_site.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "S3 website endpoint"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}
