
module "encrypt_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  context    = module.label.context
  attributes = ["encrypt"]
}

module "decrypt_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  context    = module.label.context
  attributes = ["decrypt"]
}

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
