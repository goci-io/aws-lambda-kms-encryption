locals {
  aws_region     = var.aws_region == "" ? data.aws_region.current.name : var.aws_region
  aws_account_id = var.aws_account_id == "" ? data.aws_caller_identity.current.account_id : var.aws_account_id
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = module.label.id
  tags               = module.label.tags
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    resources = [aws_kms_key.default.arn]
    actions   = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateRandom",
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", local.aws_region, local.aws_account_id, aws_cloudwatch_log_group.encrypt_log_group.function_name)
      format("arn:aws:logs:%s:%s:log-group:%s:log-stream:*", local.aws_region, local.aws_account_id, aws_cloudwatch_log_group.encrypt_log_group.function_name)
    ]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_role_policy" "lambda_access" {
  name   = module.label.id
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.policy.json
}