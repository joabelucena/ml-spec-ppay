variable "kinesis_stream_arn" {
  type        = string
  description = "Kinesis Stream ARN"
}

variable "iam_firehose_role_arn" {
  description = "Firehose role ARN"
}

variable "iam_lambda_role_arn" {
  description = "Lambda role ARN"
}

variable "parameter" {
  description = "General parameters. This is user for composing service names for example"
}

variable "tags" {
  description = "Service tags"
}
