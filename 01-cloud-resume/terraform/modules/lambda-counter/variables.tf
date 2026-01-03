variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "dynamodb_table" {
  description = "DynamoDB table name"
  type        = string
}

variable "dynamodb_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}
