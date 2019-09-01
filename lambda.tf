
resource "aws_cloudwatch_log_group" "encrypt_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.encrypt.function_name}"
  retention_in_days = 5
}

resource "aws_cloudwatch_log_group" "decrypt_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.decrypt.function_name}"
  retention_in_days = 5
}

data "archive_file" "encrypt" {
  output_path = format("%s/encrypt.zip", path.module)
  source_file = format("%s/src/encrypt.js", path.module)
  type        = "zip"
}

data "archive_file" "decrypt" {
  output_path = format("%s/decrypt.zip", path.module)
  source_file = format("%s/src/decrypt.js", path.module)
  type        = "zip"
}

resource "aws_lambda_function" "encrypt" {
  function_name    = module.encrypt_label.id
  tags             = module.encrypt_label.tags
  handler          = "encrypt.handler"
  runtime          = "nodejs8.10"
  timeout          = 10
  role             = aws_iam_role.lambda.arn
  depends_on       = [data.archive_file.encrypt]
  filename         = data.archive_file.encrypt.output_path
  source_code_hash = data.archive_file.encrypt.output_base64sha256

  environment {
    variables = {
      KMS_KEY_ARN = aws_kms_alias.default.arn
    }
  }
}

resource "aws_lambda_function" "decrypt" {
  function_name    = module.decrypt_label.id
  tags             = module.decrypt_label.tags
  handler          = "decrypt.handler"
  runtime          = "nodejs8.10"
  timeout          = 10
  role             = aws_iam_role.lambda.arn
  depends_on       = [data.archive_file.decrypt]
  filename         = data.archive_file.decrypt.output_path
  source_code_hash = data.archive_file.decrypt.output_base64sha256
}
