# Cloud Resume Challenge

> **Project #1** of the AWS Cloud Portfolio

A serverless resume website hosted on AWS, demonstrating core cloud services and Infrastructure as Code.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Browser   │────▶│  CloudFront  │────▶│     S3      │
│             │     │    (CDN)     │     │  (Static)   │
└─────────────┘     └──────────────┘     └─────────────┘
       │
       │ /count
       ▼
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ API Gateway  │────▶│   Lambda    │────▶│  DynamoDB   │
│   (HTTP)     │     │  (Python)   │     │  (Counter)  │
└──────────────┘     └─────────────┘     └─────────────┘
```

## AWS Services Used

| Service | Purpose |
|---------|---------|
| S3 | Static website hosting (HTML, CSS, JS) |
| CloudFront | CDN with HTTPS |
| API Gateway | HTTP API for visitor counter |
| Lambda | Serverless function (Python 3.11) |
| DynamoDB | NoSQL database for visitor count |
| Route53 | DNS (optional, for custom domain) |
| ACM | SSL certificate (optional) |

## Project Structure

```
01-cloud-resume/
├── terraform/
│   ├── main.tf                 # Main configuration
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   ├── versions.tf             # Provider versions
│   └── modules/
│       ├── s3-static-site/     # S3 bucket module
│       ├── cloudfront/         # CloudFront distribution
│       ├── lambda-counter/     # Lambda function
│       ├── dynamodb/           # DynamoDB table
│       └── api-gateway/        # API Gateway
├── src/
│   ├── frontend/               # Static website files
│   │   ├── index.html
│   │   ├── error.html
│   │   ├── css/styles.css
│   │   └── js/counter.js
│   └── functions/              # Lambda function code
│       ├── counter.py
│       └── requirements.txt
├── tests/                      # Unit tests
│   └── test_counter.py
├── .github/workflows/          # CI/CD pipeline
│   └── deploy.yml
└── docs/                       # Documentation
```

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform >= 1.0.0
- Python 3.11 (for local testing)

## Quick Start

### 1. Clone and navigate

```bash
cd ~/projects/etcbin.io/01-cloud-resume
```

### 2. Package Lambda function

```bash
cd src/functions
zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py
cd ../..
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Review the plan

```bash
terraform plan
```

### 5. Deploy

```bash
terraform apply
```

### 6. Get the website URL

```bash
terraform output website_url
```

## Local Development

### Run tests

```bash
pip install pytest boto3 moto
cd tests
python -m pytest test_counter.py -v
```

### Preview frontend locally

```bash
cd src/frontend
python -m http.server 8000
# Open http://localhost:8000
```

## CI/CD Pipeline

The GitHub Actions workflow:

1. **Test**: Runs Python unit tests
2. **Plan**: Generates Terraform plan
3. **Deploy** (on main): Applies Terraform, syncs S3, invalidates CloudFront

### Required Secrets

Add these to your GitHub repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## Cost Estimate

| Service | Monthly Cost |
|---------|-------------|
| S3 | $0.50 |
| CloudFront | $1.00 |
| Lambda | $0.20 |
| DynamoDB | $0.30 |
| API Gateway | $0.50 |
| **Total** | **~$2.50/month** |

Based on ~5,000 visitors/month.

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

## Lessons Learned

- CloudFront Origin Access Control (OAC) is the modern way to secure S3 access
- API Gateway HTTP APIs are simpler and cheaper than REST APIs
- DynamoDB on-demand pricing is cost-effective for low-traffic applications
- Terraform modules make infrastructure reusable

## Resume Bullet

> Designed and deployed a serverless web application on AWS using Terraform IaC; implemented CI/CD with GitHub Actions for zero-touch deployments

## Author

Hugh Nguyen - DevOps Architect
