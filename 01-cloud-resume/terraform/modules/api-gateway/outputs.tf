output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.counter_api.id
}

output "invoke_url" {
  description = "API Gateway invoke URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_endpoint" {
  description = "API Gateway endpoint"
  value       = aws_apigatewayv2_api.counter_api.api_endpoint
}
