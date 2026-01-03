# Fix #002: API Endpoint Configuration

**Date**: 2025-01-03
**Severity**: Medium (Frontend not functional until fixed)
**Status**: Resolved

---

## Problem

The visitor counter on the frontend displayed "Loading..." indefinitely and never showed the actual count. The API was working correctly when tested with `curl`, but the frontend JavaScript could not connect.

**Symptoms:**
- Counter showed "Loading..." or demo value (42)
- No network requests to API in browser dev tools
- Console log: "API endpoint not configured - displaying demo count"

---

## Root Cause

The frontend JavaScript file (`src/frontend/js/counter.js`) contained a placeholder value that was never replaced during deployment:

```javascript
// API endpoint - will be replaced during deployment
const API_ENDPOINT = 'API_ENDPOINT_PLACEHOLDER';
```

The code was designed to skip API calls when the placeholder was detected (for local development), but this meant production also skipped API calls:

```javascript
if (API_ENDPOINT === 'API_ENDPOINT_PLACEHOLDER') {
    console.log('API endpoint not configured - displaying demo count');
    updateCounterDisplay(42);
    return;
}
```

---

## Solution

### 1. Updated the JavaScript file

Changed the placeholder to the actual API Gateway endpoint:

**Before:**
```javascript
// API endpoint - will be replaced during deployment
const API_ENDPOINT = 'API_ENDPOINT_PLACEHOLDER';
```

**After:**
```javascript
// API endpoint
const API_ENDPOINT = 'https://mnsbgvacma.execute-api.us-east-1.amazonaws.com';
```

### 2. Redeployed to S3

```bash
aws s3 sync src/frontend/ s3://cloud-resume-prod-16717484/ --delete
```

### 3. Invalidated CloudFront cache

```bash
aws cloudfront create-invalidation --distribution-id EHT1OPSMSWVXI --paths "/*"
```

---

## Files Changed

| File | Change |
|------|--------|
| `src/frontend/js/counter.js` | Replaced placeholder with actual API endpoint |

---

## Verification

```bash
# Test API directly
curl -s https://mnsbgvacma.execute-api.us-east-1.amazonaws.com/count | jq
# Output: {"count": 5}

# Test increment
curl -s -X POST https://mnsbgvacma.execute-api.us-east-1.amazonaws.com/count | jq
# Output: {"count": 6}

# Visit site - counter now displays and increments
# https://d3bfu5f6po0eh.cloudfront.net
```

---

## Lessons Learned

1. **Placeholder replacement should be automated**: The deployment process should replace placeholders with actual values. Consider:
   - Using `envsubst` or `sed` in CI/CD pipeline
   - Terraform `templatefile()` function
   - Build-time environment variable injection

2. **Test the full stack**: API working via `curl` doesn't mean frontend integration works. Always test the actual user flow.

3. **Use browser dev tools**: Network tab and console would have immediately shown the issue.

---

## Prevention

For future projects, consider these approaches:

### Option A: CI/CD replacement
```yaml
# .github/workflows/deploy.yml
- name: Configure API endpoint
  run: |
    sed -i "s|API_ENDPOINT_PLACEHOLDER|${{ secrets.API_ENDPOINT }}|g" src/frontend/js/counter.js
```

### Option B: Terraform templatefile
```hcl
resource "local_file" "counter_js" {
  content = templatefile("${path.module}/templates/counter.js.tpl", {
    api_endpoint = module.api_gateway.invoke_url
  })
  filename = "${path.module}/../src/frontend/js/counter.js"
}
```

### Option C: Runtime configuration
```javascript
// Fetch config from a JSON file that Terraform generates
fetch('/config.json')
  .then(res => res.json())
  .then(config => {
    API_ENDPOINT = config.apiEndpoint;
  });
```

---

## Related

- API Gateway endpoint: `https://mnsbgvacma.execute-api.us-east-1.amazonaws.com`
- CloudFront URL: `https://d3bfu5f6po0eh.cloudfront.net`
- Route path: `/count` (not `/counter`)
