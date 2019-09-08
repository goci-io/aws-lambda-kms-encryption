
resource "aws_kms_key" "default" {
  description             = "Key to en- and decrypt secrets"
  tags                    = module.label.tags
  enable_key_rotation     = true
  deletion_window_in_days = 14
}

resource "aws_kms_alias" "default" {
  name          = format("alias/%v", module.label.id)
  target_key_id = aws_kms_key.default.id
}
