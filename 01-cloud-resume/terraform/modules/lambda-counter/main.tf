# Lambda Function for Visitor Counter

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

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
    Name        = "${var.function_name}-role"
    Environment = var.environment
  }
}

# IAM policy for Lambda to access DynamoDB and CloudWatch Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = var.dynamodb_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "counter" {
  filename         = "${path.module}/lambda.zip"
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "counter.handler"
  runtime         = "python3.11"
  timeout         = 10
  memory_size     = 128

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table
    }
  }

  tags = {
    Name        = var.function_name
    Environment = var.environment
  }

  depends_on = [aws_iam_role_policy.lambda_policy]
}

# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${var.function_name}-logs"
    Environment = var.environment
  }
}
