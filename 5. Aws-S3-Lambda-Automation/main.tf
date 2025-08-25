# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change this to your preferred region
}

# Create public S3 bucket
resource "aws_s3_bucket" "devops_public" {
  bucket = "devops-public-31470"

  tags = {
    Name        = "DevOps Public Bucket"
    Environment = "Development"
  }
}

# Configure public access block for public bucket (allow public access)
resource "aws_s3_bucket_public_access_block" "devops_public_pab" {
  bucket = aws_s3_bucket.devops_public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "devops_public_policy" {
  bucket = aws_s3_bucket.devops_public.id
  depends_on = [aws_s3_bucket_public_access_block.devops_public_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    =  [
        "s3:GetObject",
        "s3:PutObject"
      ]
        Resource  = "${aws_s3_bucket.devops_public.arn}/*"
      }
    ]
  })
}

# Create private S3 bucket
resource "aws_s3_bucket" "devops_private" {
  bucket = "devops-private-24203"

  tags = {
    Name        = "DevOps Private Bucket"
    Environment = "Development"
  }
}

# Configure public access block for private bucket (block all public access)
resource "aws_s3_bucket_public_access_block" "devops_private_pab" {
  bucket = aws_s3_bucket.devops_private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for logs
resource "aws_dynamodb_table" "devops_s3_copy_logs" {
  name           = "xfusion-S3CopyLogs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LogID"

  attribute {
    name = "LogID"
    type = "S"
  }

  tags = {
    Name        = "DevOps S3 Copy Logs"
    Environment = "Development"
  }
}

# Create IAM role for Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Lambda Execution Role"
  }
}

# Create IAM policy for Lambda function
resource "aws_iam_policy" "lambda_s3_dynamodb_policy" {
  name        = "lambda-s3-dynamodb-policy"
  description = "Policy for Lambda to access S3 and DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.devops_public.arn}/*",
          "${aws_s3_bucket.devops_private.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.devops_public.arn,
          aws_s3_bucket.devops_private.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.devops_s3_copy_logs.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_dynamodb_policy.arn
}

# Create Lambda function
resource "aws_lambda_function" "devops_copy_function" {
  filename         = "lambda-function.zip"
  function_name    = "devops-copyfunction"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "lambda-function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.devops_s3_copy_logs.name
      PRIVATE_BUCKET = aws_s3_bucket.devops_private.bucket
    }
  }

  tags = {
    Name = "DevOps Copy Function"
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_policy_attachment ]
}


# Create zip file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda-function.py"
  output_path = "lambda-function.zip"
}

# Create S3 bucket notification to trigger Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.devops_public.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.devops_copy_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

# Allow S3 to invoke Lambda function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.devops_copy_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.devops_public.arn
}

# Output values
output "public_bucket_name" {
  description = "Name of the public S3 bucket"
  value       = aws_s3_bucket.devops_public.bucket
}

output "private_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = aws_s3_bucket.devops_private.bucket
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.devops_copy_function.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.devops_s3_copy_logs.name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}