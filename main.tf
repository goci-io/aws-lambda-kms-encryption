terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws     = "~> 2.25"
    archive = "~> 1.2"
    null    = "~> 2.1"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_region        = var.aws_region == "" ? data.aws_region.current.name : var.aws_region
  aws_account_id    = var.aws_account_id == "" ? data.aws_caller_identity.current.account_id : var.aws_account_id
  named_assume_role = var.aws_assume_role_name == "" || var.aws_account_id == "" ? "" : format("arn:aws:iam::%s:role/%s", var.aws_account_id, var.aws_assume_role_name)
  assume_role_arn   = var.aws_assume_role_arn == "" ? local.named_assume_role : var.aws_assume_role_arn
}

provider "aws" {
  dynamic "assume_role" {
    iterator = role
    for_each = local.assume_role_arn == "" ? [] : [local.assume_role_arn]

    content {
      role_arn = role.value
    }
  }
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = concat(var.attributes, [var.region])
  tags       = merge(var.tags, { Region = var.region, Purpose = "Cryptography" })
}
