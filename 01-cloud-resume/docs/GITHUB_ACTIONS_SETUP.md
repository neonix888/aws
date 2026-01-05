# GitHub Actions CI/CD Setup

This guide explains how to configure GitHub Actions for automated deployment.

---

## Overview

The CI/CD pipeline automatically:
1. Runs unit tests on every PR
2. Validates Terraform configuration
3. Deploys to AWS on merge to `main`

---

## Prerequisites

- AWS Account
- GitHub repository with this code
- AWS CLI installed locally (for IAM setup)

---

## Step 1: Create IAM User for GitHub Actions

### Option A: Using AWS CLI (Recommended)

```bash
# Create the IAM user
aws iam create-user --user-name github-actions-cloud-resume

# Attach the policy (create policy first - see Step 2)
aws iam attach-user-policy \
  --user-name github-actions-cloud-resume \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsCloudResumePolicy

# Create access keys
aws iam create-access-key --user-name github-actions-cloud-resume
```

Save the `AccessKeyId` and `SecretAccessKey` from the output.

### Option B: Using AWS Console

1. Go to **IAM** → **Users** → **Create user**
2. User name: `github-actions-cloud-resume`
3. Select **Attach policies directly**
4. Create and attach the policy from Step 2
5. Go to **Security credentials** → **Create access key**
6. Select **Third-party service** → Create
7. Save the Access Key ID and Secret Access Key

---

## Step 2: Create IAM Policy (Least Privilege)

Create a policy named `GitHubActionsCloudResumePolicy` with this JSON:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3FullAccessForTerraform",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:GetBucketCORS",
        "s3:PutBucketCORS",
        "s3:GetBucketWebsite",
        "s3:PutBucketWebsite",
        "s3:DeleteBucketWebsite",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:DeleteObjectVersion",
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "arn:aws:s3:::cloud-resume-*",
        "arn:aws:s3:::cloud-resume-*/*"
      ]
    },
    {
      "Sid": "CloudFrontManagement",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:UpdateDistribution",
        "cloudfront:TagResource",
        "cloudfront:UntagResource",
        "cloudfront:ListTagsForResource",
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations",
        "cloudfront:CreateOriginAccessControl",
        "cloudfront:DeleteOriginAccessControl",
        "cloudfront:GetOriginAccessControl",
        "cloudfront:UpdateOriginAccessControl",
        "cloudfront:ListOriginAccessControls",
        "cloudfront:GetCachePolicy",
        "cloudfront:ListCachePolicies",
        "cloudfront:GetOriginRequestPolicy",
        "cloudfront:ListOriginRequestPolicies"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBManagement",
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTable",
        "dynamodb:UpdateTable",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:TagResource",
        "dynamodb:UntagResource",
        "dynamodb:ListTagsOfResource",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:UpdateTimeToLive",
        "dynamodb:DescribeContinuousBackups"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/cloud-resume-*"
    },
    {
      "Sid": "LambdaManagement",
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:AddPermission",
        "lambda:RemovePermission",
        "lambda:GetPolicy",
        "lambda:TagResource",
        "lambda:UntagResource",
        "lambda:ListTags",
        "lambda:ListVersionsByFunction",
        "lambda:PublishVersion",
        "lambda:InvokeFunction"
      ],
      "Resource": "arn:aws:lambda:*:*:function:cloud-resume-*"
    },
    {
      "Sid": "APIGatewayManagement",
      "Effect": "Allow",
      "Action": [
        "apigateway:POST",
        "apigateway:GET",
        "apigateway:PUT",
        "apigateway:DELETE",
        "apigateway:PATCH",
        "apigateway:TagResource",
        "apigateway:UntagResource"
      ],
      "Resource": [
        "arn:aws:apigateway:*::/apis",
        "arn:aws:apigateway:*::/apis/*",
        "arn:aws:apigateway:*::/tags/*"
      ]
    },
    {
      "Sid": "IAMRoleManagement",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:UpdateRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:GetRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::*:role/cloud-resume-*"
    },
    {
      "Sid": "CloudWatchLogsManagement",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:PutRetentionPolicy",
        "logs:DeleteRetentionPolicy",
        "logs:TagLogGroup",
        "logs:UntagLogGroup",
        "logs:ListTagsLogGroup",
        "logs:TagResource",
        "logs:UntagResource",
        "logs:ListTagsForResource"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/lambda/cloud-resume-*",
        "arn:aws:logs:*:*:log-group:/aws/api-gateway/cloud-resume-*"
      ]
    },
    {
      "Sid": "CloudWatchLogsWildcard",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
```

### Create Policy via AWS CLI

Save the above JSON to a file named `github-actions-policy.json`, then:

```bash
aws iam create-policy \
  --policy-name GitHubActionsCloudResumePolicy \
  --policy-document file://github-actions-policy.json
```

---

## Step 3: Add Secrets to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these two secrets:

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | Access key from Step 1 |
| `AWS_SECRET_ACCESS_KEY` | Secret key from Step 1 |

---

## Step 4: Verify Setup

After adding secrets, any push to `main` branch will trigger the workflow.

To test:
```bash
# From your local repo
git checkout main
git merge dev
git push origin main
```

Then go to **Actions** tab in GitHub to watch the workflow run.

---

## Security Best Practices

1. **Never commit credentials** - Always use GitHub Secrets
2. **Rotate keys regularly** - Every 90 days recommended
3. **Use least privilege** - This policy only allows `cloud-resume-*` resources
4. **Monitor usage** - Check CloudTrail for API activity
5. **Delete keys when not needed** - If you stop using CI/CD, delete the IAM user

---

## Customizing for Your Project

If you fork/clone this repo and want to use different resource names:

1. **Update the IAM policy** - Change `cloud-resume-*` to your project prefix
2. **Update Terraform variables** - Change `project_name` in `variables.tf`
3. **Update workflow** - If you change directory structure

### Example: Changing project prefix to `my-portfolio`

In the IAM policy, replace all occurrences of:
- `cloud-resume-*` → `my-portfolio-*`

In `terraform/variables.tf`:
```hcl
variable "project_name" {
  default = "my-portfolio"  # Changed from cloud-resume
}
```

---

## Troubleshooting

### Error: "Access Denied"

Check:
1. IAM policy is attached to the user
2. Resource names match the policy patterns
3. AWS region matches

### Error: "InvalidClientTokenId"

Check:
1. `AWS_ACCESS_KEY_ID` secret is correct
2. No extra spaces in the secret value
3. Access key is active (not deleted/disabled)

### Error: "Unable to locate credentials"

Check:
1. Both secrets are added to GitHub
2. Secret names are exactly `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

---

## IAM Policy Explanation

| Statement | Purpose |
|-----------|---------|
| S3FullAccessForTerraform | Create/manage S3 buckets and objects |
| CloudFrontManagement | Create/manage CloudFront distributions |
| DynamoDBManagement | Create/manage DynamoDB tables |
| LambdaManagement | Create/manage Lambda functions |
| APIGatewayManagement | Create/manage API Gateway |
| IAMRoleManagement | Create Lambda execution role |
| CloudWatchLogsManagement | Create log groups for Lambda/API Gateway |

All permissions are scoped to resources matching `cloud-resume-*` pattern where possible.

---

## Cleanup

To remove the GitHub Actions IAM user:

```bash
# Detach policy
aws iam detach-user-policy \
  --user-name github-actions-cloud-resume \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsCloudResumePolicy

# Delete access keys (get key ID first)
aws iam list-access-keys --user-name github-actions-cloud-resume
aws iam delete-access-key \
  --user-name github-actions-cloud-resume \
  --access-key-id ACCESS_KEY_ID_HERE

# Delete user
aws iam delete-user --user-name github-actions-cloud-resume

# Optional: Delete policy
aws iam delete-policy \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubActionsCloudResumePolicy
```
