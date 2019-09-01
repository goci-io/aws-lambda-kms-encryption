terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws     = "~> 2.25"
    archive = "~> 1.2"
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
