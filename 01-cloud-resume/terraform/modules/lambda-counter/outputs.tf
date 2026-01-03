output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.counter.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.counter.arn
}

output "invoke_arn" {
  description = "Lambda function invoke ARN (for API Gateway)"
  value       = aws_lambda_function.counter.invoke_arn
}
