# Testing Guide

Complete guide for testing the Cloud Resume Challenge project.

---

## Test Categories

| Type | Purpose | Tools |
|------|---------|-------|
| Unit Tests | Test Lambda function logic | pytest, moto |
| Integration Tests | Test AWS service interactions | AWS CLI, curl |
| E2E Tests | Test complete user flow | Browser, curl |
| Local Testing | Test frontend without deploying | Python HTTP server |

---

## Prerequisites

### Python Environment Setup

```bash
cd ~/projects/etcbin.io/01-cloud-resume

# Activate virtual environment
source venv/bin/activate

# Install test dependencies
pip install pytest boto3 moto
```

### Verify Installation

```bash
pytest --version
python -c "import moto; print(moto.__version__)"
```

---

## Unit Tests

### Run All Tests

```bash
cd ~/projects/etcbin.io/01-cloud-resume

# Run with verbose output
python -m pytest tests/test_counter.py -v
```

Expected output:
```
tests/test_counter.py::test_get_counter PASSED
tests/test_counter.py::test_increment_counter PASSED
tests/test_counter.py::test_handler_get PASSED
tests/test_counter.py::test_handler_post PASSED
tests/test_counter.py::test_cors_headers PASSED

========================= 5 passed in 2.34s =========================
```

### Run Specific Test

```bash
# Run single test
python -m pytest tests/test_counter.py::test_increment_counter -v

# Run tests matching pattern
python -m pytest tests/ -k "handler" -v
```

### Run with Coverage

```bash
# Install coverage
pip install pytest-cov

# Run with coverage report
python -m pytest tests/test_counter.py --cov=src.functions.counter --cov-report=term-missing
```

Expected output:
```
Name                         Stmts   Miss  Cover   Missing
----------------------------------------------------------
src/functions/counter.py        35      2    94%   67-68
----------------------------------------------------------
TOTAL                           35      2    94%
```

### Test Output Formats

```bash
# JUnit XML (for CI/CD)
python -m pytest tests/ --junitxml=test-results.xml

# HTML report
pip install pytest-html
python -m pytest tests/ --html=test-report.html
```

---

## What the Tests Cover

### test_get_counter
- Tests `get_counter()` function
- Verifies it returns 0 for new counter
- Uses moto to mock DynamoDB

### test_increment_counter
- Tests `increment_counter()` function
- Verifies counter increments correctly
- Tests atomic update behavior

### test_handler_get
- Tests Lambda handler with GET request
- Verifies 200 status code
- Verifies response contains count

### test_handler_post
- Tests Lambda handler with POST request
- Verifies counter increments
- Verifies response format

### test_cors_headers
- Tests CORS headers are present
- Verifies `Access-Control-Allow-Origin: *`
- Important for browser compatibility

---

## Local Frontend Testing

### Start Local Server

```bash
cd ~/projects/etcbin.io/01-cloud-resume/src/frontend

# Start Python HTTP server
python -m http.server 8000
```

Open `http://localhost:8000` in browser.

### Expected Behavior (Local)

When running locally with placeholder API:
- Page loads correctly
- Counter shows "42" (demo value)
- Console shows: "API endpoint not configured - displaying demo count"

### Test with Live API

If AWS is deployed, test with real API:

```bash
# Get API endpoint
cd ~/projects/etcbin.io/01-cloud-resume/terraform
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Temporarily update counter.js for local testing
cd ../src/frontend/js
# Edit counter.js and replace API_ENDPOINT value
```

---

## Integration Tests (Post-Deployment)

Run these after deploying to AWS.

### API Gateway Tests

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test GET endpoint
echo "Testing GET /count..."
curl -s "${API_ENDPOINT}/count" | jq .

# Test POST endpoint (increment)
echo "Testing POST /count..."
curl -s -X POST "${API_ENDPOINT}/count" | jq .

# Test CORS preflight
echo "Testing OPTIONS (CORS)..."
curl -s -X OPTIONS "${API_ENDPOINT}/count" \
  -H "Origin: https://example.com" \
  -H "Access-Control-Request-Method: POST" \
  -v 2>&1 | grep -i "access-control"
```

Expected responses:
```json
{"count": 5}
{"count": 6}
```

### DynamoDB Tests

```bash
TABLE_NAME=$(terraform output -raw dynamodb_table_name)

# Read current value
aws dynamodb get-item \
  --table-name ${TABLE_NAME} \
  --key '{"id": {"S": "visitor_count"}}'

# Describe table
aws dynamodb describe-table --table-name ${TABLE_NAME}
```

### Lambda Tests

```bash
FUNCTION_NAME="cloud-resume-counter"

# Invoke directly
aws lambda invoke \
  --function-name ${FUNCTION_NAME} \
  --payload '{"requestContext": {"http": {"method": "GET"}}}' \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json | jq .

# Check recent logs
aws logs tail "/aws/lambda/${FUNCTION_NAME}" --since 1h
```

### CloudFront Tests

```bash
WEBSITE_URL=$(terraform output -raw website_url)

# Test website loads
curl -s -I ${WEBSITE_URL} | head -20

# Test cache headers
curl -s -I ${WEBSITE_URL}/css/styles.css | grep -i cache

# Test HTTPS redirect
curl -s -I -L http://$(echo ${WEBSITE_URL} | sed 's/https:\/\///')
```

### S3 Tests

```bash
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# List objects
aws s3 ls s3://${BUCKET_NAME}/

# Check bucket policy
aws s3api get-bucket-policy --bucket ${BUCKET_NAME}

# Verify public access is blocked
aws s3api get-public-access-block --bucket ${BUCKET_NAME}
```

---

## End-to-End Tests

### Manual Browser Test

1. Open website URL in browser
2. Verify page loads with resume content
3. Check visitor counter shows a number
4. Refresh page - counter should increment
5. Open browser DevTools (F12):
   - Network tab: Check API call succeeds
   - Console: No errors

### Automated E2E (Optional)

Using curl to simulate browser:

```bash
#!/bin/bash
WEBSITE_URL=$(terraform output -raw website_url)

echo "=== E2E Test Suite ==="

# Test 1: Homepage loads
echo -n "Test 1: Homepage loads... "
STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${WEBSITE_URL})
[ "$STATUS" = "200" ] && echo "PASS" || echo "FAIL (HTTP $STATUS)"

# Test 2: CSS loads
echo -n "Test 2: CSS loads... "
STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${WEBSITE_URL}/css/styles.css)
[ "$STATUS" = "200" ] && echo "PASS" || echo "FAIL (HTTP $STATUS)"

# Test 3: JS loads
echo -n "Test 3: JavaScript loads... "
STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${WEBSITE_URL}/js/counter.js)
[ "$STATUS" = "200" ] && echo "PASS" || echo "FAIL (HTTP $STATUS)"

# Test 4: API responds
echo -n "Test 4: API responds... "
API_ENDPOINT=$(terraform output -raw api_endpoint)
RESPONSE=$(curl -s "${API_ENDPOINT}/count")
echo $RESPONSE | jq -e '.count' > /dev/null && echo "PASS" || echo "FAIL"

# Test 5: Counter increments
echo -n "Test 5: Counter increments... "
COUNT1=$(curl -s "${API_ENDPOINT}/count" | jq -r '.count')
COUNT2=$(curl -s -X POST "${API_ENDPOINT}/count" | jq -r '.count')
[ "$COUNT2" -gt "$COUNT1" ] && echo "PASS" || echo "FAIL"

echo "=== Tests Complete ==="
```

---

## Terraform Tests

### Validate Configuration

```bash
cd ~/projects/etcbin.io/01-cloud-resume/terraform

terraform init
terraform validate
```

### Plan Review

```bash
terraform plan -out=tfplan

# Review plan for issues
terraform show tfplan
```

### Format Check

```bash
# Check formatting
terraform fmt -check -recursive

# Auto-format if needed
terraform fmt -recursive
```

---

## CI/CD Test Integration

Tests run automatically in GitHub Actions:

### Test Job

```yaml
# From .github/workflows/deploy.yml
test:
  name: Run Tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    - run: |
        pip install pytest boto3 moto
        python -m pytest tests/test_counter.py -v
```

### Viewing Test Results

1. Go to GitHub repository
2. Click "Actions" tab
3. Select workflow run
4. Expand "Run Tests" step

---

## Troubleshooting Tests

### Import Errors

**Error**: `ModuleNotFoundError: No module named 'src'`

**Solution**: Run tests from project root:
```bash
cd ~/projects/etcbin.io/01-cloud-resume
python -m pytest tests/
```

### Moto Warnings

**Warning**: `UserWarning: Module X not available`

**Solution**: These are optional dependencies, safe to ignore.

### AWS Credentials Error

**Error**: `botocore.exceptions.NoCredentialsError`

**Solution**: The tests use moto mocks. Ensure test file sets dummy credentials:
```python
os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
```

### DynamoDB Table Not Found

**Error**: `ResourceNotFoundException`

**Solution**: Verify table name matches in test fixture:
```python
os.environ['TABLE_NAME'] = 'test-visitors'
# Must match table created in fixture
```

---

## Adding New Tests

### Test Structure

```python
# tests/test_new_feature.py
import pytest
from moto import mock_aws

@pytest.fixture
def setup():
    """Setup fixture."""
    with mock_aws():
        # Setup code
        yield

@mock_aws
def test_feature(setup):
    """Test description."""
    # Arrange
    # Act
    # Assert
    assert result == expected
```

### Running New Tests

```bash
# Run new test file
python -m pytest tests/test_new_feature.py -v

# Run all tests
python -m pytest tests/ -v
```

---

## Test Checklist

Before deploying, verify:

- [ ] All unit tests pass
- [ ] No new test warnings
- [ ] Coverage remains high (>90%)
- [ ] Terraform validates
- [ ] Local frontend renders correctly

After deploying, verify:

- [ ] Website loads
- [ ] Counter displays number
- [ ] Counter increments
- [ ] No browser console errors
- [ ] API responds correctly
- [ ] CloudWatch logs clean
