# Cloud Resume Challenge - Main Terraform Configuration
# Architecture: S3 -> CloudFront -> API Gateway -> Lambda -> DynamoDB

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Random suffix for globally unique S3 bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
}

# DynamoDB table for visitor counter
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name   = "${var.project_name}-visitors"
  environment  = var.environment
}

# S3 bucket for static website hosting
module "s3_static_site" {
  source = "./modules/s3-static-site"

  bucket_name = local.bucket_name
  environment = var.environment
}

# Lambda function for visitor counter
module "lambda_counter" {
  source = "./modules/lambda-counter"

  function_name    = "${var.project_name}-counter"
  dynamodb_table   = module.dynamodb.table_name
  dynamodb_arn     = module.dynamodb.table_arn
  environment      = var.environment
}

# API Gateway for Lambda
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name           = "${var.project_name}-api"
  lambda_invoke_arn  = module.lambda_counter.invoke_arn
  lambda_function_name = module.lambda_counter.function_name
  environment        = var.environment
}

# CloudFront distribution
module "cloudfront" {
  source = "./modules/cloudfront"

  s3_bucket_id                = module.s3_static_site.bucket_id
  s3_bucket_regional_domain   = module.s3_static_site.bucket_regional_domain_name
  api_gateway_invoke_url      = module.api_gateway.invoke_url
  environment                 = var.environment
}
