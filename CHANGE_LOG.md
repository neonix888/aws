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
  - `docs/DEPLOY.md` - Complete deployment guide with prerequisites, steps, verification, troubleshooting
  - `docs/TESTING.md` - Testing procedures (unit, integration, E2E, local testing)
  - `docs/OPERATIONS.md` - Operations guide (monitoring, logs, costs, destroy, maintenance)
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

### Fixed
- **Fix #001**: Renamed `src/lambda/` to `src/functions/` to avoid Python reserved keyword conflict
  - `lambda` is a reserved keyword in Python, causing syntax errors during test imports
  - Added `__init__.py` files for proper Python package structure
  - Updated all references in tests, CI/CD workflow, and documentation
  - See `docs/fixes/001-lambda-reserved-keyword.md` for full details

---

## Version History

### 2026-01-04 - Documentation Enhancement & Deployment Verification

**Deployment Verified**
- Confirmed Project #1 is fully deployed to AWS
- Website live at: https://d3bfu5f6po0eh.cloudfront.net
- API live at: https://mnsbgvacma.execute-api.us-east-1.amazonaws.com/count
- Visitor counter functional (4 visits recorded)
- Terraform state matches AWS infrastructure (no drift)

**Documentation Added**
- Created `docs/DEPLOY.md` - Comprehensive deployment guide
  - Prerequisites and tool requirements
  - Step-by-step deployment instructions
  - Post-deployment verification
  - Troubleshooting section
  - Quick deploy script
- Created `docs/TESTING.md` - Complete testing guide
  - Unit test instructions with pytest/moto
  - Integration tests for AWS services
  - End-to-end test procedures
  - Local frontend testing
  - CI/CD test integration
- Created `docs/OPERATIONS.md` - Operations runbook
  - Monitoring with CloudWatch metrics
  - Log access and management
  - Cost tracking and optimization
  - Maintenance procedures
  - Complete destroy instructions with backup
  - Disaster recovery procedures

---

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
- [x] Initialize git repository (dev branch)
- [x] Run Python unit tests - PASSED
- [x] Validate Terraform configuration - NO DRIFT
- [x] Deploy Project #1 to AWS - DEPLOYED
- [x] Test end-to-end functionality - VERIFIED
- [ ] Push to GitHub (after approval)
- [ ] Write blog post for Project #1

### Future
- Project #2: Backup & Archival System
- Project #3: Three-Tier Architecture
- Continue through roadmap
