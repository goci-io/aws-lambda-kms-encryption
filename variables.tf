variable "name" {
  type        = string
  description = "A name to uniquly identify this encryption method"
  default     = "encryption"
}

variable "stage" {
  type        = string
  description = "The stage the lambda will be deployed into"
}

variable "namespace" {
  type        = string
  description = "Company or organization prefix (eg: goci)"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "region" {
  type        = string
  description = "The own region region label to append to the function name"
  default     = "eu1"
}

variable "aws_region" {
  type        = string
  default     = ""
  description = "The AWS region the lambda and log group will be deployed into"
}

variable "aws_account_id" {
  type        = string
  default     = ""
  description = "The AWS Account the lambda and log group will be deployed into"
}
