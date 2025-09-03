# AWS Lambda Function and Terraform Configuration

## Explanation on the Usage of Handlers

This section explains each part of the Lambda function configuration in detail:

```hcl
handler = "lambda-function.lambda_handler"
```

The **handler** specifies the entry point for your Lambda function. It follows the format:

```
filename.function_name
```

- **lambda-function** – The name of your Python file (without the `.py` extension).
- **lambda_handler** – The name of the function inside that file that AWS Lambda will call.

Example:

```python
def lambda_handler(event, context):
    # Your code here
    return response
```

AWS Lambda looks for the `lambda_handler` function inside `lambda-function.py` when invoked.

---

### Source Code Hash

```hcl
source_code_hash = data.archive_file.lambda_zip.output_base64sha256
```

This is a **change detection mechanism** for Terraform:

- `data.archive_file.lambda_zip` refers to the data source that creates a ZIP file from your Python code.
- `output_base64sha256` is a checksum (hash) of the ZIP file contents.

Terraform compares this hash during `terraform apply`. If the hash differs (meaning your code changed), Terraform updates the Lambda function automatically.

---

### Runtime

```hcl
runtime = "python3.9"
```

This specifies the execution environment for your Lambda function. Examples include:

- `python3.8`, `python3.9`, `python3.10`, `python3.11`
- `nodejs18.x`, `java11`, etc.

The runtime determines which libraries and language features are available.

---

### Timeout

```hcl
timeout = 60
```

- Sets the maximum execution time (in seconds).
- Default is 3 seconds, max is 900 seconds (15 minutes).
- AWS terminates the function if it exceeds the timeout.

---

### Why These Settings Matter

- **Handler:** Must match your file and function names exactly.
- **Source Code Hash:** Ensures changes trigger redeployment.
- **Runtime:** Must match your code and libraries.
- **Timeout:** Should balance expected execution time and cost.

---

## Explanation on Using `archive_file` Data Source

In Terraform, **data sources** retrieve information or perform operations but don't create infrastructure. Example:

```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "/root/lambda-function.py"
  output_path = "lambda-function.zip"
}
```

### How It Works

- **type = "zip"** – AWS Lambda requires code to be uploaded as ZIP files.
- **source_file** – Input Python file.
- **output_path** – Output ZIP file to be uploaded to Lambda.

AWS Lambda references this ZIP in your function definition:

```hcl
resource "aws_lambda_function" "devops_copy_function" {
  filename         = "lambda-function.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
```

---

### Updating the Lambda Function

When you modify `/root/lambda-function.py`:

1. Terraform detects changes.
2. Creates a new ZIP.
3. Updates the Lambda function.

---

### Using a Source Directory

To package an entire directory:

```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "/root/lambda-code/"
  output_path = "lambda-function.zip"
}
```

To exclude certain files:

```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "/root/lambda-code/"
  output_path = "lambda-function.zip"
  excludes    = ["__pycache__", "*.pyc"]
}
```

---

## Key Takeaways

- **ZIP Packaging** is required for Lambda.
- **archive_file** simplifies change tracking.
- **Terraform** ensures automated updates when code changes.