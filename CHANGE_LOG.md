# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- Initial project structure for AWS Cloud Portfolio
- Project #1: Cloud Resume Challenge scaffold
  - Terraform modules: S3, CloudFront, Lambda, DynamoDB, API Gateway
  - Lambda function for visitor counter (Python 3.11)
  - Frontend: HTML resume with CSS styling and JS counter
  - GitHub Actions CI/CD workflow
  - Unit tests with pytest and moto
- Documentation
  - `docs/architecture.md` - System architecture
  - `docs/terraform-structure.md` - Terraform IaC documentation
  - `docs/folder-structure.md` - Project layout
- `ROADMAP.md` - Portfolio roadmap with all 10 projects
- `CHANGE_LOG.md` - This file
- Nginx configuration for projects.etcbin.io
- SSL certificate via Let's Encrypt

### Infrastructure
- Created directory structure for all 10 projects
- Set up projects.etcbin.io subdomain
- Configured HTTPS with security headers

### Security
- No hardcoded secrets or credentials
- S3 bucket configured with block public access
- CloudFront Origin Access Control (OAC)
- Least-privilege IAM roles

---

## Version History

### 2025-01-03 - Project Initialization

**Session Start**
- Created AWS account (Free Tier eligible)
- Installed and configured AWS CLI v2
- Set up IAM user `portfolio-admin` with access keys
- Configured billing alerts

**Infrastructure Setup**
- Created `~/projects/etcbin.io/` directory structure
- Created DNS A record for projects.etcbin.io
- Configured nginx for projects.etcbin.io
- Obtained SSL certificate from Let's Encrypt
- Deployed placeholder page

**Project #1 Scaffold**
- Created Terraform module structure
- Wrote Lambda visitor counter function
- Created HTML/CSS/JS frontend
- Set up GitHub Actions workflow
- Created unit tests
- Created documentation

---

## Upcoming

### Next Session
- [ ] Validate Terraform configuration
- [ ] Deploy Project #1 to AWS
- [ ] Test end-to-end functionality
- [ ] Initialize git repository
- [ ] Push to GitHub (after approval)

### Future
- Project #2: Backup & Archival System
- Project #3: Three-Tier Architecture
- Continue through roadmap
