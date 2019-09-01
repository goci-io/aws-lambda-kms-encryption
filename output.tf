output "encrypt_function" {
  value = aws_lambda_function.encrypt.arn
}

output "encrypt_log_group" {
  value = aws_cloudwatch_log_group.encrypt_log_group.arn
}

output "decrypt_function" {
  value = aws_lambda_function.decrypt.arn
}

output "decrypt_log_group" {
  value = aws_cloudwatch_log_group.decrypt_log_group.arn
}

output "kms_key_alias" {
  value = aws_kms_alias.default.arn
}

output "kms_key_alias_target_arn" {
  value = aws_kms_alias.default.target_key_arn
}
