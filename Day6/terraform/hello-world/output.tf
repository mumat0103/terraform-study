output "api_url" {
  value = aws_apigatewayv2_stage.lambda_api_stage.invoke_url
}
