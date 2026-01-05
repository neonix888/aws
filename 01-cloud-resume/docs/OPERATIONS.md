# Operations Guide

Guide for managing, monitoring, and destroying the Cloud Resume infrastructure.

---

## Table of Contents

1. [Resource Overview](#resource-overview)
2. [Monitoring](#monitoring)
3. [Logs](#logs)
4. [Cost Tracking](#cost-tracking)
5. [Maintenance](#maintenance)
6. [Destroy Infrastructure](#destroy-infrastructure)
7. [Disaster Recovery](#disaster-recovery)

---

## Resource Overview

### Deployed Resources

| Service | Resource Name | Purpose |
|---------|---------------|---------|
| S3 | `cloud-resume-prod-XXXXXX` | Static website files |
| CloudFront | `E1234567890ABC` | CDN distribution |
| DynamoDB | `cloud-resume-visitors` | Visitor counter |
| Lambda | `cloud-resume-counter` | Counter API logic |
| API Gateway | `cloud-resume-api` | HTTP API |
| CloudWatch | Log groups | Logs and metrics |
| IAM | Lambda execution role | Permissions |

### Get Resource Details

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform

# All outputs
terraform output

# Specific output
terraform output website_url
terraform output api_endpoint
terraform output s3_bucket_name
terraform output cloudfront_distribution_id
terraform output dynamodb_table_name
```

---

## Monitoring

### CloudWatch Dashboard (Manual Setup)

Create a dashboard in AWS Console:
1. Go to CloudWatch > Dashboards
2. Create dashboard: `cloud-resume-dashboard`
3. Add widgets for:
   - Lambda invocations
   - Lambda errors
   - API Gateway requests
   - CloudFront requests

### Key Metrics

#### Lambda Metrics

```bash
# Invocation count (last hour)
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=cloud-resume-counter \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum

# Error count
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=cloud-resume-counter \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum

# Duration (average)
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=cloud-resume-counter \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Average
```

#### API Gateway Metrics

```bash
API_ID=$(aws apigatewayv2 get-apis --query "Items[?Name=='cloud-resume-api'].ApiId" --output text)

# Request count
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApiGateway \
  --metric-name Count \
  --dimensions Name=ApiId,Value=${API_ID} \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum
```

#### CloudFront Metrics

```bash
DIST_ID=$(terraform output -raw cloudfront_distribution_id)

# Request count
aws cloudwatch get-metric-statistics \
  --namespace AWS/CloudFront \
  --metric-name Requests \
  --dimensions Name=DistributionId,Value=${DIST_ID} Name=Region,Value=Global \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum \
  --region us-east-1
```

### Set Up Alarms

```bash
# Alarm for Lambda errors
aws cloudwatch put-metric-alarm \
  --alarm-name "cloud-resume-lambda-errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --dimensions Name=FunctionName,Value=cloud-resume-counter
```

---

## Logs

### Lambda Logs

```bash
# Stream logs in real-time
aws logs tail "/aws/lambda/cloud-resume-counter" --follow

# View last hour
aws logs tail "/aws/lambda/cloud-resume-counter" --since 1h

# View last 100 events
aws logs tail "/aws/lambda/cloud-resume-counter" --since 1h --format short | tail -100

# Search for errors
aws logs filter-log-events \
  --log-group-name "/aws/lambda/cloud-resume-counter" \
  --filter-pattern "ERROR" \
  --start-time $(date -u -d '1 day ago' +%s000)
```

### API Gateway Logs

```bash
# API Gateway access logs (if enabled)
aws logs tail "/aws/api-gateway/cloud-resume-api" --since 1h
```

### Log Retention

Default retention is set to 14 days. To modify:

```bash
# Set retention to 7 days
aws logs put-retention-policy \
  --log-group-name "/aws/lambda/cloud-resume-counter" \
  --retention-in-days 7
```

### Export Logs

```bash
# Export to S3 (for long-term storage)
aws logs create-export-task \
  --log-group-name "/aws/lambda/cloud-resume-counter" \
  --from $(date -u -d '7 days ago' +%s000) \
  --to $(date -u +%s000) \
  --destination "your-log-bucket" \
  --destination-prefix "cloud-resume-logs"
```

---

## Cost Tracking

### Estimated Monthly Cost

| Service | Estimate | Notes |
|---------|----------|-------|
| S3 | $0.50 | Storage + requests |
| CloudFront | $1.00 | Data transfer |
| Lambda | $0.20 | Free tier covers most |
| DynamoDB | $0.30 | On-demand pricing |
| API Gateway | $0.50 | Per request |
| CloudWatch | $0.50 | Logs storage |
| **Total** | **~$3/month** | Based on ~5K visitors |

### Check Current Usage

```bash
# Get current month's cost (requires Cost Explorer enabled)
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter '{"Dimensions": {"Key": "SERVICE", "Values": ["Amazon Simple Storage Service", "Amazon CloudFront", "Amazon DynamoDB", "AWS Lambda", "Amazon API Gateway"]}}'
```

### Set Billing Alerts

1. Go to AWS Console > Billing > Budgets
2. Create budget:
   - Name: `cloud-resume-monthly`
   - Amount: $10
   - Alert at 80% and 100%

### Cost Optimization

- **CloudFront**: Already using PriceClass_100 (cheapest)
- **Lambda**: 128MB is sufficient
- **DynamoDB**: On-demand avoids over-provisioning
- **Logs**: Set short retention to reduce storage

---

## Maintenance

### Update Frontend Content

```bash
cd ~/projects/etcbin.io/01-cloud-resume

# Edit files in src/frontend/

# Sync to S3
BUCKET=$(cd terraform && terraform output -raw s3_bucket_name)
aws s3 sync src/frontend/ s3://${BUCKET}/ --delete

# Invalidate cache
DIST_ID=$(cd terraform && terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths "/*"
```

### Update Lambda Function

```bash
cd ~/projects/etcbin.io/01-cloud-resume

# Edit src/functions/counter.py

# Repackage
cd src/functions
zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py

# Deploy
cd ../../terraform
terraform apply -target=module.lambda_counter
```

### View Current Visitor Count

```bash
TABLE=$(terraform output -raw dynamodb_table_name)

aws dynamodb get-item \
  --table-name ${TABLE} \
  --key '{"id": {"S": "visitor_count"}}' \
  --query 'Item.count.N' \
  --output text
```

### Reset Visitor Counter

```bash
TABLE=$(terraform output -raw dynamodb_table_name)

aws dynamodb put-item \
  --table-name ${TABLE} \
  --item '{"id": {"S": "visitor_count"}, "count": {"N": "0"}}'
```

### CloudFront Cache Invalidation

```bash
DIST_ID=$(terraform output -raw cloudfront_distribution_id)

# Invalidate everything
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths "/*"

# Invalidate specific file
aws cloudfront create-invalidation --distribution-id ${DIST_ID} --paths "/index.html"

# Check invalidation status
aws cloudfront list-invalidations --distribution-id ${DIST_ID}
```

---

## Destroy Infrastructure

### Pre-Destroy Checklist

- [ ] Backup any important data (visitor count, logs)
- [ ] Confirm no other services depend on these resources
- [ ] Ensure you're destroying the correct environment

### Backup Data Before Destroy

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform

# Export visitor count
TABLE=$(terraform output -raw dynamodb_table_name)
aws dynamodb scan --table-name ${TABLE} > ~/dynamodb-backup.json

# Export logs
aws logs tail "/aws/lambda/cloud-resume-counter" --since 30d > ~/lambda-logs-backup.txt

# Download S3 content
BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 sync s3://${BUCKET}/ ~/s3-backup/
```

### Empty S3 Bucket

S3 buckets must be empty before Terraform can destroy them:

```bash
BUCKET=$(terraform output -raw s3_bucket_name)

# Delete all objects
aws s3 rm s3://${BUCKET}/ --recursive

# Delete all versions (if versioning enabled)
aws s3api list-object-versions --bucket ${BUCKET} --output json | \
  jq -r '.Versions[]? | "--key \"\(.Key)\" --version-id \(.VersionId)"' | \
  xargs -L1 aws s3api delete-object --bucket ${BUCKET}

# Delete all delete markers
aws s3api list-object-versions --bucket ${BUCKET} --output json | \
  jq -r '.DeleteMarkers[]? | "--key \"\(.Key)\" --version-id \(.VersionId)"' | \
  xargs -L1 aws s3api delete-object --bucket ${BUCKET}
```

### Destroy Command

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform

# Plan destruction first
terraform plan -destroy

# Destroy all resources
terraform destroy
```

Type `yes` when prompted.

### Verify Destruction

```bash
# Check no resources remain
terraform show

# Verify in AWS Console:
# - S3: Bucket deleted
# - CloudFront: Distribution deleted
# - DynamoDB: Table deleted
# - Lambda: Function deleted
# - API Gateway: API deleted
```

### Cleanup Local Files

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform

# Remove Terraform state and cache
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
rm -f tfplan

# Remove Lambda package
rm -f modules/lambda-counter/lambda.zip
```

### Quick Destroy Script

```bash
#!/bin/bash
set -e

cd ~/projects/etcbin.io/01-cloud-resume/terraform

echo "=== Cloud Resume Teardown ==="

# Get bucket name before destroy
BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")

if [ -n "$BUCKET" ]; then
  echo "[1/3] Emptying S3 bucket..."
  aws s3 rm s3://${BUCKET}/ --recursive
fi

echo "[2/3] Destroying Terraform resources..."
terraform destroy -auto-approve

echo "[3/3] Cleaning up local files..."
rm -rf .terraform/
rm -f .terraform.lock.hcl terraform.tfstate* tfplan
rm -f modules/lambda-counter/lambda.zip

echo "=== Teardown Complete ==="
```

---

## Disaster Recovery

### Redeploy from Scratch

If something goes wrong, you can always redeploy:

```bash
cd ~/projects/etcbin.io/01-cloud-resume

# Package Lambda
cd src/functions && zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py && cd ../..

# Deploy
cd terraform
terraform init
terraform apply
```

### Restore Visitor Count

If you backed up the counter:

```bash
TABLE=$(terraform output -raw dynamodb_table_name)
COUNT=123  # Your backed up count

aws dynamodb put-item \
  --table-name ${TABLE} \
  --item "{\"id\": {\"S\": \"visitor_count\"}, \"count\": {\"N\": \"${COUNT}\"}}"
```

### Common Issues After Redeploy

1. **Different CloudFront URL**: Update any bookmarks or links
2. **Different API endpoint**: Update counter.js and redeploy frontend
3. **Counter reset to 0**: Restore from backup

---

## Operational Runbook

### Daily Checks

```bash
# Quick health check script
cd ~/projects/etcbin.io/01-cloud-resume/terraform

WEBSITE=$(terraform output -raw website_url)
API=$(terraform output -raw api_endpoint)

echo "Website status: $(curl -s -o /dev/null -w '%{http_code}' ${WEBSITE})"
echo "API status: $(curl -s -o /dev/null -w '%{http_code}' ${API}/count)"
echo "Counter value: $(curl -s ${API}/count | jq -r '.count')"
echo "Lambda errors (1h): $(aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=cloud-resume-counter \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 3600 \
  --statistics Sum \
  --query 'Datapoints[0].Sum' \
  --output text)"
```

### Weekly Tasks

- Review CloudWatch logs for errors
- Check AWS billing dashboard
- Verify SSL certificate status (auto-renewed)

### Monthly Tasks

- Review and rotate AWS access keys
- Check for Terraform provider updates
- Review CloudFront cache hit ratio
