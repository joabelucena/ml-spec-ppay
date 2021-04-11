variable "iam_glue_role_arn" {
  description = "Glue role ARN"
}

variable "s3_bucket_path" {
  description = "Target path"
}

variable "parameter" {
  description = "General parameters. This is user for composing service names for example"
}

variable "tags" {
  description = "Service tags"
}
