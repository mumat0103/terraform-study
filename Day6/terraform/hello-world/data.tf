data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "hello-world.py"
  output_path = "hello-world.zip"
}
