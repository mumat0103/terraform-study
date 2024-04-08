module "lambda" {
  source        = "./hello-world"
  function_name = "csk-lambda-hello-function"
  role_arn      = aws_iam_role.lambda_role.arn
}
