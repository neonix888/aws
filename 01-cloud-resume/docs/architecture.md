# Architecture Documentation

## Cloud Resume Challenge - System Architecture

### Overview

This project implements a serverless resume website with a visitor counter, demonstrating core AWS services and Infrastructure as Code principles.

### Architecture Diagram

```
                                    ┌─────────────────────────────────────┐
                                    │           AWS Cloud                 │
                                    │                                     │
┌──────────┐                        │  ┌─────────────┐    ┌───────────┐  │
│  User    │───── HTTPS ───────────▶│  │ CloudFront  │───▶│    S3     │  │
│ Browser  │                        │  │    (CDN)    │    │ (Static)  │  │
└──────────┘                        │  └─────────────┘    └───────────┘  │
     │                              │         │                          │
     │                              │         │ Origin Access Control    │
     │ POST /count                  │         ▼                          │
     │                              │  ┌─────────────┐                   │
     └──────────────────────────────▶  │ API Gateway │                   │
                                    │  │   (HTTP)    │                   │
                                    │  └──────┬──────┘                   │
                                    │         │                          │
                                    │         ▼                          │
                                    │  ┌─────────────┐    ┌───────────┐  │
                                    │  │   Lambda    │───▶│ DynamoDB  │  │
                                    │  │  (Python)   │    │ (Counter) │  │
                                    │  └─────────────┘    └───────────┘  │
                                    │                                     │
                                    └─────────────────────────────────────┘
```

### Components

#### 1. CloudFront (CDN)

- **Purpose**: Content delivery and HTTPS termination
- **Configuration**:
  - Price class: PriceClass_100 (US, Canada, Europe)
  - Default root object: index.html
  - Cache behavior: Optimized for static content
  - Origin Access Control (OAC) for S3 security

#### 2. S3 (Static Website Hosting)

- **Purpose**: Store and serve static files (HTML, CSS, JS)
- **Security**:
  - Block all public access enabled
  - Access only via CloudFront OAC
  - Server-side encryption (AES-256)
  - Versioning enabled

#### 3. API Gateway (HTTP API)

- **Purpose**: Expose Lambda function as REST endpoint
- **Endpoints**:
  - `GET /count` - Retrieve current visitor count
  - `POST /count` - Increment and return visitor count
- **Features**:
  - CORS enabled
  - Access logging to CloudWatch
  - Auto-deploy stage

#### 4. Lambda (Serverless Compute)

- **Purpose**: Business logic for visitor counter
- **Runtime**: Python 3.11
- **Configuration**:
  - Memory: 128 MB
  - Timeout: 10 seconds
  - IAM role with least-privilege access

#### 5. DynamoDB (NoSQL Database)

- **Purpose**: Persist visitor count
- **Configuration**:
  - Billing mode: PAY_PER_REQUEST (on-demand)
  - Single table design with partition key `id`
  - Atomic counter updates

### Data Flow

1. User visits the website
2. Browser requests static content from CloudFront
3. CloudFront serves cached content or fetches from S3
4. JavaScript calls API Gateway endpoint
5. API Gateway invokes Lambda function
6. Lambda updates DynamoDB counter atomically
7. Response returns through the chain to browser

### Security Considerations

| Layer | Security Measure |
|-------|------------------|
| CloudFront | HTTPS only, TLS 1.2+ |
| S3 | Private bucket, OAC access only, encryption at rest |
| API Gateway | CORS configured, rate limiting available |
| Lambda | Least-privilege IAM role, VPC optional |
| DynamoDB | Encryption at rest, IAM-based access |

### Cost Optimization

- CloudFront: PriceClass_100 limits to cheaper regions
- Lambda: 128MB memory is sufficient for this workload
- DynamoDB: On-demand pricing avoids provisioned capacity costs
- S3: Standard storage class with lifecycle policies available

### Scalability

- CloudFront: Automatic global scaling
- API Gateway: Automatic scaling, 10,000 requests/second default
- Lambda: Automatic scaling, 1,000 concurrent executions default
- DynamoDB: On-demand mode scales automatically

### Monitoring

- CloudFront: Access logs, real-time metrics
- API Gateway: Access logs, CloudWatch metrics
- Lambda: CloudWatch Logs (14-day retention), metrics
- DynamoDB: CloudWatch metrics, on-demand capacity metrics
