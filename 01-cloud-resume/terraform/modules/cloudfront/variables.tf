variable "s3_bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "s3_bucket_regional_domain" {
  description = "S3 bucket regional domain name"
  type        = string
}

variable "api_gateway_invoke_url" {
  description = "API Gateway invoke URL"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}
