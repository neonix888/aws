# Deployment Guide

Complete guide to deploy the Cloud Resume Challenge to AWS.

---

## Prerequisites

### Required Tools

| Tool | Version | Check Command |
|------|---------|---------------|
| AWS CLI | v2.x | `aws --version` |
| Terraform | >= 1.6.0 | `terraform --version` |
| Python | 3.11+ | `python3 --version` |
| zip | any | `zip --version` |

### AWS Account Setup

1. **AWS Account**: Free Tier eligible account
2. **IAM User**: Create a user with programmatic access
3. **Permissions**: Attach the following policies:
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
   - `AmazonDynamoDBFullAccess`
   - `AWSLambda_FullAccess`
   - `AmazonAPIGatewayAdministrator`
   - `IAMFullAccess` (for creating Lambda execution role)
   - `CloudWatchLogsFullAccess`

### AWS CLI Configuration

```bash
# Configure AWS credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/portfolio-admin"
}
```

---

## Deployment Steps

### Step 1: Navigate to Project

```bash
cd ~/projects/etcbin.io/01-cloud-resume
```

### Step 2: Package Lambda Function

The Lambda function must be zipped before Terraform can deploy it.

```bash
cd src/functions
zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py
cd ../..
```

Verify the package:
```bash
ls -la terraform/modules/lambda-counter/lambda.zip
# Should show ~2KB file
```

### Step 3: Initialize Terraform

```bash
cd terraform
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Finding hashicorp/random versions matching "~> 3.0"...
- Installing hashicorp/aws v5.x.x...
- Installing hashicorp/random v3.x.x...

Terraform has been successfully initialized!
```

### Step 4: Validate Configuration

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 5: Review the Plan

```bash
terraform plan -out=tfplan
```

Review the output carefully. You should see:
- 1 S3 bucket
- 1 CloudFront distribution
- 1 DynamoDB table
- 1 Lambda function
- 1 API Gateway
- Associated IAM roles and policies

Resource count: **~15-20 resources**

### Step 6: Deploy to AWS

```bash
terraform apply tfplan
```

Or without a saved plan:
```bash
terraform apply
```

Type `yes` when prompted.

Deployment takes approximately **3-5 minutes** (CloudFront distribution is the slowest).

### Step 7: Get Outputs

```bash
terraform output
```

Expected outputs:
```
api_endpoint = "https://xxxxxxxxxx.execute-api.us-east-1.amazonaws.com"
cloudfront_distribution_id = "E1234567890ABC"
dynamodb_table_name = "cloud-resume-visitors"
s3_bucket_name = "cloud-resume-prod-abc12345"
website_url = "https://d1234567890abc.cloudfront.net"
```

Save these values - you'll need them for the next steps.

### Step 8: Update Frontend API Endpoint

The JavaScript file needs the actual API endpoint:

```bash
# Get the API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Update counter.js
cd ../src/frontend/js
sed -i "s|API_ENDPOINT_PLACEHOLDER|${API_ENDPOINT}|g" counter.js

# Verify the change
grep "API_ENDPOINT" counter.js
```

### Step 9: Upload Frontend to S3

```bash
# Get bucket name
BUCKET_NAME=$(cd ../../../terraform && terraform output -raw s3_bucket_name)

# Sync frontend files to S3
cd ../..  # Back to src/frontend
aws s3 sync . s3://${BUCKET_NAME}/ --delete
```

### Step 10: Invalidate CloudFront Cache

```bash
# Get distribution ID
DIST_ID=$(cd ../../terraform && terraform output -raw cloudfront_distribution_id)

# Create invalidation
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths "/*"
```

---

## Post-Deployment Verification

### 1. Verify Website

```bash
# Get URL
terraform output website_url
```

Open the URL in a browser. You should see:
- The resume page loads
- Visitor counter displays a number
- Counter increments on refresh

### 2. Verify API

```bash
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test GET
curl -s "${API_ENDPOINT}/count" | jq .

# Test POST (increment)
curl -s -X POST "${API_ENDPOINT}/count" | jq .
```

Expected response:
```json
{
  "count": 1
}
```

### 3. Verify DynamoDB

```bash
TABLE_NAME=$(terraform output -raw dynamodb_table_name)

aws dynamodb get-item \
  --table-name ${TABLE_NAME} \
  --key '{"id": {"S": "visitor_count"}}'
```

### 4. Check CloudWatch Logs

```bash
# List Lambda log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/cloud-resume"

# View recent logs
aws logs tail "/aws/lambda/cloud-resume-counter" --since 1h
```

---

## Quick Deploy Script

For convenience, here's a complete deployment script:

```bash
#!/bin/bash
set -e

PROJECT_DIR=~/projects/etcbin.io/01-cloud-resume

echo "=== Cloud Resume Deployment ==="

# Package Lambda
echo "[1/6] Packaging Lambda..."
cd ${PROJECT_DIR}/src/functions
zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py

# Terraform
echo "[2/6] Initializing Terraform..."
cd ${PROJECT_DIR}/terraform
terraform init

echo "[3/6] Applying Terraform..."
terraform apply -auto-approve

# Get outputs
echo "[4/6] Getting outputs..."
API_ENDPOINT=$(terraform output -raw api_endpoint)
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
DIST_ID=$(terraform output -raw cloudfront_distribution_id)
WEBSITE_URL=$(terraform output -raw website_url)

# Update frontend
echo "[5/6] Updating and uploading frontend..."
cd ${PROJECT_DIR}/src/frontend/js
sed -i "s|API_ENDPOINT_PLACEHOLDER|${API_ENDPOINT}|g" counter.js
cd ..
aws s3 sync . s3://${BUCKET_NAME}/ --delete

# Invalidate cache
echo "[6/6] Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths "/*"

echo ""
echo "=== Deployment Complete ==="
echo "Website URL: ${WEBSITE_URL}"
echo "API Endpoint: ${API_ENDPOINT}"
```

---

## Troubleshooting

### Terraform Init Fails

**Error**: `Error: Failed to query available provider packages`

**Solution**: Check internet connectivity and try again:
```bash
terraform init -upgrade
```

### S3 Bucket Name Conflict

**Error**: `BucketAlreadyExists`

**Solution**: S3 bucket names are globally unique. The random suffix should prevent this, but if it happens:
```bash
terraform destroy
terraform apply
```

### Lambda Permission Denied

**Error**: `AccessDeniedException` when Lambda accesses DynamoDB

**Solution**: Verify IAM policy is attached:
```bash
aws lambda get-function --function-name cloud-resume-counter
# Check the Role ARN and verify DynamoDB permissions
```

### CloudFront 403 Error

**Error**: Website returns 403 Forbidden

**Solution**: Check S3 bucket policy allows CloudFront OAC:
```bash
aws s3api get-bucket-policy --bucket ${BUCKET_NAME}
```

### API CORS Error

**Error**: Browser console shows CORS error

**Solution**: Verify API Gateway CORS settings:
```bash
aws apigatewayv2 get-api --api-id ${API_ID}
```

### Counter Shows "--"

**Issue**: Counter displays "--" instead of a number

**Causes**:
1. API endpoint not updated in counter.js
2. API Gateway not deployed
3. Lambda function error

**Debug**:
```bash
# Check counter.js has correct endpoint
grep "API_ENDPOINT" src/frontend/js/counter.js

# Test API directly
curl -v ${API_ENDPOINT}/count
```

---

## CI/CD Deployment (GitHub Actions)

The project includes automated deployment via GitHub Actions.

### Setup

1. Add repository secrets in GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Push to `main` branch to trigger deployment

### Workflow Overview

| Job | Trigger | Actions |
|-----|---------|---------|
| `test` | PR, Push | Run Python tests |
| `terraform-plan` | PR, Push | Validate and plan |
| `deploy` | Push to main | Apply and sync |

### Manual Trigger

To deploy manually via CI/CD:
1. Create a PR to `main`
2. Review the Terraform plan in the PR checks
3. Merge to `main`
4. Deployment runs automatically

---

## Next Steps

After successful deployment:
1. Test the live site
2. Monitor CloudWatch for errors
3. Set up billing alerts
4. Consider adding a custom domain (Route53 + ACM)

See `OPERATIONS.md` for monitoring and maintenance.
