output "website_url" {
  description = "CloudFront distribution URL"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

output "s3_bucket_name" {
  description = "S3 bucket name for static content"
  value       = module.s3_static_site.bucket_id
}

output "api_endpoint" {
  description = "API Gateway endpoint for visitor counter"
  value       = module.api_gateway.invoke_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = module.cloudfront.distribution_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}
