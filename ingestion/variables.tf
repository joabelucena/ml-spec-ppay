variable "iam_lambda_role_arn" {
  description = "Lambda role ARN"
}

variable "kinesis_stream_name" {
  description = "The target stream name for lambda deliverying records"
}

variable "parameter" {
  description = "General parameters. This is user for composing service names for example"
}

variable "tags" {
  description = "Service tags"
}
