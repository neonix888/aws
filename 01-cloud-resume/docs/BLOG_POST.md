# Blog Post: Cloud Resume Challenge

> **Status**: Draft
> **Target Platform**: [Medium / Dev.to / LinkedIn / Personal Site]
> **Publish Date**: TBD

---

## Title Ideas

- "Building a Serverless Resume with AWS: A Cloud Resume Challenge Journey"
- "From Zero to Deployed: My AWS Cloud Resume in Terraform"
- "What I Learned Building a Serverless Portfolio on AWS"

---

## What I Built

A serverless resume website hosted entirely on AWS, featuring:

- **Static website** hosted on S3 and served via CloudFront CDN
- **Visitor counter** powered by API Gateway, Lambda, and DynamoDB
- **Infrastructure as Code** using Terraform with modular design
- **CI/CD pipeline** with GitHub Actions for automated deployments

### Architecture

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

**Live Demo**: [CloudFront URL]
**Source Code**: https://github.com/neonix888/aws

---

## Technologies Used

| Technology | Purpose | Why I Chose It |
|------------|---------|----------------|
| **S3** | Static hosting | Cost-effective, highly durable, native AWS integration |
| **CloudFront** | CDN | Global edge locations, HTTPS, caching |
| **API Gateway** | HTTP API | Serverless, auto-scaling, pay-per-request |
| **Lambda** | Backend logic | No servers to manage, Python runtime |
| **DynamoDB** | Database | Serverless, on-demand pricing, millisecond latency |
| **Terraform** | IaC | Declarative, modular, state management |
| **GitHub Actions** | CI/CD | Native GitHub integration, free tier |

---

## Challenges Encountered

### Challenge 1: Python Reserved Keyword

**Problem**: Named my Lambda directory `lambda/`, which is a reserved keyword in Python. Tests failed with syntax errors during imports.

**Solution**: Renamed to `functions/` and updated all references.

**Lesson**: Always check for language reserved words when naming directories.

### Challenge 2: S3 Bucket Deletion with Versioning

**Problem**: `terraform destroy` failed because S3 bucket had versioned objects. Error: "BucketNotEmpty".

**Solution**: Added `force_destroy = true` to the S3 bucket resource.

**Lesson**: Plan for teardown from the start. Versioning is great for data protection but complicates cleanup.

### Challenge 3: API Endpoint Configuration

**Problem**: Frontend JavaScript needed the API Gateway URL, but this URL isn't known until after deployment.

**Solution**: Used a placeholder in development, CI/CD pipeline injects actual URL during deployment.

**Lesson**: Dynamic configuration between frontend and backend requires planning.

---

## What I Learned

1. **Modular Terraform is worth the effort** - Separating each AWS service into its own module made the code reusable and easier to understand.

2. **Serverless isn't zero-ops** - Still need to think about IAM permissions, logging, error handling, and monitoring.

3. **Documentation-first pays off** - Writing docs as I built helped clarify my thinking and will help others (and future me).

4. **Infrastructure as Code is powerful** - Being able to `terraform destroy` and `terraform apply` to recreate everything identically is incredibly valuable.

---

## What I'd Do Differently

1. **Start with remote state** - I used local state for simplicity, but for a real project, S3 backend with DynamoDB locking would be better.

2. **Add monitoring from day one** - CloudWatch alarms and dashboards should be part of the initial deployment, not an afterthought.

3. **Implement proper testing** - While I have unit tests, integration tests against real AWS resources would catch more issues.

---

## Cost Breakdown

| Service | Monthly Cost |
|---------|-------------|
| S3 | ~$0.50 |
| CloudFront | ~$1.00 |
| Lambda | ~$0.20 |
| DynamoDB | ~$0.30 |
| API Gateway | ~$0.50 |
| **Total** | **~$2.50/month** |

All resources can be destroyed when not in use to save costs.

---

## Next Steps

- Project #2: Backup & Archival System (S3 Glacier, lifecycle policies)
- Eventually: 10 production-grade AWS projects demonstrating hands-on cloud engineering

---

## Resources

- [Cloud Resume Challenge](https://cloudresumechallenge.dev/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Serverless Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

---

## Tags

`#AWS` `#Terraform` `#Serverless` `#CloudResume` `#DevOps` `#InfrastructureAsCode`
