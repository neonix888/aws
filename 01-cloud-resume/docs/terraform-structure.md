# Terraform Structure Documentation

## Overview

This project uses Terraform to provision all AWS infrastructure. The code is organized into reusable modules following Terraform best practices.

## Directory Structure

```
terraform/
├── main.tf              # Root module - orchestrates all modules
├── variables.tf         # Input variables with defaults
├── outputs.tf           # Output values for reference
├── versions.tf          # Provider and Terraform version constraints
└── modules/
    ├── s3-static-site/  # S3 bucket for static hosting
    ├── cloudfront/      # CloudFront distribution
    ├── lambda-counter/  # Lambda function and IAM
    ├── dynamodb/        # DynamoDB table
    └── api-gateway/     # API Gateway HTTP API
```

## Root Module

### main.tf

Orchestrates all child modules and defines:
- AWS provider configuration
- Random ID for unique S3 bucket names
- Module instantiation with dependencies

### variables.tf

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for resources |
| `project_name` | string | `cloud-resume` | Project name for resource naming |
| `environment` | string | `prod` | Environment identifier |
| `domain_name` | string | `projects.etcbin.io` | Domain for the resume site |
| `tags` | map(string) | See file | Common tags for all resources |

### outputs.tf

| Output | Description |
|--------|-------------|
| `website_url` | CloudFront distribution URL |
| `s3_bucket_name` | S3 bucket name |
| `api_endpoint` | API Gateway endpoint URL |
| `cloudfront_distribution_id` | For cache invalidation |
| `dynamodb_table_name` | DynamoDB table name |

## Modules

### s3-static-site

**Purpose**: Creates S3 bucket for static website hosting

**Resources**:
- `aws_s3_bucket` - Main bucket (`force_destroy = true` for clean teardown)
- `aws_s3_bucket_public_access_block` - Block public access
- `aws_s3_bucket_versioning` - Enable versioning
- `aws_s3_bucket_server_side_encryption_configuration` - AES-256 encryption
- `aws_s3_bucket_website_configuration` - Website settings

**Key Configuration**:
```hcl
force_destroy = true  # Allows terraform destroy to delete bucket with all contents
```
> **Note**: This enables clean `terraform destroy` without manual bucket emptying.
> For production with critical data, set to `false` and backup before destroying.

**Inputs**:
- `bucket_name` - Unique bucket name
- `environment` - Environment tag

**Outputs**:
- `bucket_id` - Bucket name
- `bucket_arn` - Bucket ARN
- `bucket_regional_domain_name` - For CloudFront origin
- `website_endpoint` - S3 website endpoint

### cloudfront

**Purpose**: Creates CloudFront distribution for CDN

**Resources**:
- `aws_cloudfront_origin_access_control` - OAC for S3
- `aws_cloudfront_distribution` - CDN distribution
- `aws_s3_bucket_policy` - Allow CloudFront access

**Inputs**:
- `s3_bucket_id` - S3 bucket ID
- `s3_bucket_regional_domain` - S3 domain for origin
- `api_gateway_invoke_url` - API endpoint (for future use)
- `environment` - Environment tag

**Outputs**:
- `distribution_id` - For cache invalidation
- `distribution_domain_name` - CloudFront URL
- `distribution_arn` - Distribution ARN

### lambda-counter

**Purpose**: Creates Lambda function for visitor counter

**Resources**:
- `aws_iam_role` - Execution role
- `aws_iam_role_policy` - DynamoDB and CloudWatch permissions
- `aws_lambda_function` - Function definition
- `aws_cloudwatch_log_group` - Log retention

**Inputs**:
- `function_name` - Lambda function name
- `dynamodb_table` - Table name for counter
- `dynamodb_arn` - Table ARN for IAM policy
- `environment` - Environment tag

**Outputs**:
- `function_name` - Lambda name
- `function_arn` - Lambda ARN
- `invoke_arn` - For API Gateway integration

### dynamodb

**Purpose**: Creates DynamoDB table for visitor count

**Resources**:
- `aws_dynamodb_table` - Table with on-demand billing
- `aws_dynamodb_table_item` - Initial counter value

**Inputs**:
- `table_name` - DynamoDB table name
- `environment` - Environment tag

**Outputs**:
- `table_name` - Table name
- `table_arn` - Table ARN

### api-gateway

**Purpose**: Creates HTTP API for Lambda integration

**Resources**:
- `aws_apigatewayv2_api` - HTTP API with CORS
- `aws_apigatewayv2_integration` - Lambda integration
- `aws_apigatewayv2_route` - GET and POST routes
- `aws_apigatewayv2_stage` - Auto-deploy stage
- `aws_cloudwatch_log_group` - Access logs
- `aws_lambda_permission` - Allow API Gateway to invoke Lambda

**Inputs**:
- `api_name` - API Gateway name
- `lambda_invoke_arn` - Lambda invoke ARN
- `lambda_function_name` - Lambda name for permission
- `environment` - Environment tag

**Outputs**:
- `api_id` - API Gateway ID
- `invoke_url` - API endpoint URL
- `api_endpoint` - API endpoint

## Usage

### Initialize

```bash
cd terraform
terraform init
```

### Plan

```bash
terraform plan -out=tfplan
```

### Apply

```bash
terraform apply tfplan
```

### Destroy

```bash
terraform destroy
```

## Best Practices Followed

1. **Modular Design**: Each AWS service is a separate module
2. **Variable Defaults**: Sensible defaults with override capability
3. **Output Values**: Key information exposed for reference
4. **Tagging**: Consistent tags across all resources
5. **Security**: Least-privilege IAM, encryption enabled
6. **Cost Optimization**: On-demand pricing, minimal resources

## State Management

For production use, configure remote state:

```hcl
# backend.tf (create when ready)
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "cloud-resume/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Dependencies

Module dependencies are handled automatically by Terraform based on input/output references:

```
dynamodb ──┐
           ├──▶ lambda-counter ──┐
s3-static-site ──────────────────┼──▶ cloudfront
                                 │
           ┌─────────────────────┘
           ▼
      api-gateway
```
