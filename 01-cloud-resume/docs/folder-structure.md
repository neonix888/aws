# Folder Structure Documentation

## Project Layout

```
01-cloud-resume/
│
├── .github/
│   └── workflows/
│       └── deploy.yml           # CI/CD pipeline configuration
│
├── docs/
│   ├── architecture.md          # System architecture documentation
│   ├── terraform-structure.md   # Terraform IaC documentation
│   └── folder-structure.md      # This file
│
├── src/
│   ├── frontend/                # Static website files
│   │   ├── css/
│   │   │   └── styles.css       # Stylesheet
│   │   ├── js/
│   │   │   └── counter.js       # Visitor counter script
│   │   ├── index.html           # Main resume page
│   │   └── error.html           # 404 error page
│   │
│   └── lambda/                  # Lambda function code
│       ├── counter.py           # Visitor counter function
│       └── requirements.txt     # Python dependencies
│
├── terraform/
│   ├── modules/                 # Reusable Terraform modules
│   │   ├── api-gateway/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── cloudfront/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── dynamodb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── lambda-counter/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── lambda.zip       # Packaged function (generated)
│   │   └── s3-static-site/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── main.tf                  # Root module configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   └── versions.tf              # Provider versions
│
├── tests/
│   └── test_counter.py          # Unit tests for Lambda function
│
├── .gitignore                   # Git ignore patterns
└── README.md                    # Project documentation
```

## Directory Descriptions

### `.github/workflows/`

Contains GitHub Actions workflow definitions for CI/CD automation.

- `deploy.yml`: Main deployment pipeline
  - Runs tests on all PRs
  - Plans Terraform changes
  - Deploys on merge to main

### `docs/`

Project documentation in Markdown format.

- `architecture.md`: System design and component descriptions
- `terraform-structure.md`: IaC organization and module details
- `folder-structure.md`: This file - project layout reference

### `src/frontend/`

Static website files deployed to S3.

- `index.html`: Main resume page with semantic HTML
- `error.html`: Custom 404 error page
- `css/styles.css`: Responsive stylesheet with CSS variables
- `js/counter.js`: Visitor counter API integration

### `src/lambda/`

Python code for AWS Lambda functions.

- `counter.py`: Visitor counter logic with DynamoDB integration
- `requirements.txt`: Python package dependencies

### `terraform/`

Infrastructure as Code using Terraform.

- Root level files define the main configuration
- `modules/` contains reusable, composable modules
- Each module follows standard structure: main.tf, variables.tf, outputs.tf

### `tests/`

Automated tests for code quality assurance.

- `test_counter.py`: Unit tests using pytest and moto for AWS mocking

## File Naming Conventions

| Pattern | Usage |
|---------|-------|
| `*.tf` | Terraform configuration files |
| `*.py` | Python source code |
| `*.md` | Documentation files |
| `*.html` | HTML templates |
| `*.css` | Stylesheets |
| `*.js` | JavaScript files |
| `*.yml` | YAML configuration (GitHub Actions) |
| `*.zip` | Packaged Lambda functions |

## Generated Files (Not in Git)

These files are generated during build/deploy and excluded via `.gitignore`:

- `terraform/.terraform/` - Provider plugins
- `terraform/*.tfstate*` - Terraform state files
- `terraform/.terraform.lock.hcl` - Dependency lock
- `__pycache__/` - Python bytecode
- `*.zip` - Lambda packages
- `.env*` - Environment files
