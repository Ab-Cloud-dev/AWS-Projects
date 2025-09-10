provider "aws" {
  region = "us-east-1"  # Specify the AWS region for resource deployment
}

# Create a DynamoDB table for storing student records
resource "aws_dynamodb_table" "student_table" {
  name         = "Student"
  billing_mode = "PAY_PER_REQUEST"  # Use on-demand billing for flexibility
  hash_key     = "studentid"  # Define the partition key

  attribute {
    name = "studentid"
    type = "S"  # String type for the partition key
  }

  tags = {
    Name = "StudentTable"
  }
}

# Create IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name               = "student_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Attach policies to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function for getting student data
resource "aws_lambda_function" "get_student" {
  function_name = "getStudent"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"  # Specify the handler function
  runtime       = "python3.8"  # Specify the runtime environment

  # Package the Lambda function code
  filename      = "src/lambdas/getStudent/app.zip"  # Path to the zipped code
  source_code_hash = filebase64sha256("src/lambdas/getStudent/app.zip")

  environment {
    TABLE_NAME = aws_dynamodb_table.student_table.name  # Pass the DynamoDB table name as an environment variable
  }
}

# Create the Lambda function for inserting student data
resource "aws_lambda_function" "insert_student" {
  function_name = "insertStudent"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"

  filename      = "src/lambdas/insertStudent/app.zip"
  source_code_hash = filebase64sha256("src/lambdas/insertStudent/app.zip")

  environment {
    TABLE_NAME = aws_dynamodb_table.student_table.name
  }
}

# Create API Gateway for the Lambda functions
resource "aws_api_gateway_rest_api" "student_api" {
  name        = "student_api"
  description = "API for managing student records"
}

resource "aws_api_gateway_resource" "students" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  parent_id   = aws_api_gateway_rest_api.student_api.root_resource_id
  path_part   = "students"
}

resource "aws_api_gateway_method" "get_student" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "GET"
  authorization = "NONE"

  integration {
    type             = "AWS_PROXY"
    integration_http_method = "POST"
    uri              = aws_lambda_function.get_student.invoke_arn
  }
}

resource "aws_api_gateway_method" "insert_student" {
  rest_api_id   = aws_api_gateway_rest_api.student_api.id
  resource_id   = aws_api_gateway_resource.students.id
  http_method   = "POST"
  authorization = "NONE"

  integration {
    type             = "AWS_PROXY"
    integration_http_method = "POST"
    uri              = aws_lambda_function.insert_student.invoke_arn
  }
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "student_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.student_api.id
  stage_name  = "prod"  # Define the deployment stage
}

# Output the API endpoint
output "api_endpoint" {
  value = "${aws_api_gateway_deployment.student_api_deployment.invoke_url}/students"
}