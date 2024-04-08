resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  architectures = ["x86_64"]
  memory_size   = 128
  timeout       = 10
  runtime       = "python3.12"
  handler       = "hello-world.lambda_handler"
  filename      = "hello-world.zip"
  role          = var.role_arn

  environment {
    variables = {
      TEST = "TEST"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "csk-lambda-api"
  protocol_type = "HTTP"

}

resource "aws_apigatewayv2_stage" "lambda_api_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "csk-lambda-api-stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_api_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST" # lambda에는 POST 요청을 보냄
}

resource "aws_apigatewayv2_route" "lambda_api_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /" # 사용자한테는 GET 요청을 받음
  target    = "integrations/${aws_apigatewayv2_integration.lambda_api_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_event_rule" "lambda_event_rule" {
  name                = "csk-lambda-event-rule"
  schedule_expression = "rate(1 minute)" # 2분이 넘어가면 minutes
  # cron * * * * *
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  rule      = aws_cloudwatch_event_rule.lambda_event_rule.name
  target_id = "lambda-target" # 이벤트 타겟의 이름 (생성되는 이름)
  arn       = aws_lambda_function.lambda.arn
  input     = <<EOF
  {
    "ddps":"lab"
  }
  EOF
}

resource "aws_lambda_permission" "eventbridge_permission" {
  statement_id  = "eventallow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_event_rule.arn
}
