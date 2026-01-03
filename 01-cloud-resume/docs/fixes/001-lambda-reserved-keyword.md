# Fix #001: Lambda Reserved Keyword Issue

**Date**: 2025-01-03
**Severity**: Critical (Tests could not run)
**Status**: Resolved

---

## Problem

Python tests failed to run with the following error:

```
E     File "/home/carloacutis/projects/etcbin.io/01-cloud-resume/tests/test_counter.py", line 59
E       from src.lambda.counter import get_counter
E                ^^^^^^
E   SyntaxError: invalid syntax
```

## Root Cause

`lambda` is a **reserved keyword** in Python. It is used to create anonymous functions:

```python
# Python lambda keyword usage
square = lambda x: x * x
```

When Python's import system encountered `from src.lambda.counter`, it interpreted `lambda` as the keyword, not a directory name, causing a syntax error.

**Original directory structure**:
```
src/
├── frontend/
└── lambda/           # Problem: 'lambda' is reserved
    └── counter.py
```

## Solution

### 1. Renamed directory

Changed `src/lambda/` to `src/functions/`:

```bash
cd ~/projects/etcbin.io/01-cloud-resume/src
mv lambda functions
```

### 2. Created Python package markers

Added `__init__.py` files to make directories proper Python packages:

```bash
touch src/__init__.py
touch src/functions/__init__.py
touch tests/__init__.py
```

### 3. Updated import statements

Changed all imports in `tests/test_counter.py`:

**Before**:
```python
from src.lambda.counter import get_counter
with patch('src.lambda.counter.table', dynamodb_table):
```

**After**:
```python
from src.functions.counter import get_counter
with patch('src.functions.counter.table', dynamodb_table):
```

### 4. Updated GitHub Actions workflow

Changed `.github/workflows/deploy.yml`:

**Before**:
```yaml
- name: Package Lambda function
  run: |
    cd src/lambda
    zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py
```

**After**:
```yaml
- name: Package Lambda function
  run: |
    cd src/functions
    zip -r ../../terraform/modules/lambda-counter/lambda.zip counter.py
```

### 5. Updated documentation

Updated the following files:
- `README.md` - Project structure and commands
- `docs/folder-structure.md` - Directory descriptions

---

## Files Changed

| File | Change |
|------|--------|
| `src/lambda/` | Renamed to `src/functions/` |
| `src/__init__.py` | Created (new) |
| `src/functions/__init__.py` | Created (new) |
| `tests/__init__.py` | Created (new) |
| `tests/test_counter.py` | Updated imports |
| `.github/workflows/deploy.yml` | Updated paths |
| `README.md` | Updated directory structure |
| `docs/folder-structure.md` | Updated directory structure |

---

## Lessons Learned

1. **Avoid Python reserved keywords as directory/file names**:
   - `lambda`, `class`, `def`, `import`, `from`, `return`, `if`, `else`, `for`, `while`, `try`, `except`, `with`, `as`, `is`, `in`, `not`, `and`, `or`, `True`, `False`, `None`

2. **Always create `__init__.py` files** for Python packages when imports are needed across directories

3. **Run tests early** in the development process to catch these issues

4. **Use descriptive directory names** that clearly indicate purpose:
   - `functions/` instead of `lambda/`
   - `handlers/` for request handlers
   - `services/` for business logic

---

## Verification

Tests now pass:

```bash
cd ~/projects/etcbin.io/01-cloud-resume
source venv/bin/activate
python -m pytest tests/test_counter.py -v

# Output:
# tests/test_counter.py::test_get_counter PASSED
# tests/test_counter.py::test_increment_counter PASSED
# tests/test_counter.py::test_handler_get PASSED
# tests/test_counter.py::test_handler_post PASSED
# tests/test_counter.py::test_cors_headers PASSED
```

---

## Prevention

For future projects:
1. Use linters like `pylint` or `flake8` that can catch reserved keyword issues
2. Establish naming conventions in project documentation
3. Run tests as part of pre-commit hooks
