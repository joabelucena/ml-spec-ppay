variable kinesis_stream_arn {
  type        = string
  description = "Kinesis Stream ARN"
}

variable "iam_firehose_role_arn" {
  description = "Firehose role ARN"
}