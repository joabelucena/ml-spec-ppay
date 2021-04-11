# Criacao do bucket
resource "aws_s3_bucket" "raw_bucket" {
  bucket        = "picpay-raw-bucket"
  acl           = "private"
  force_destroy = true

  tags = var.tags
}


resource "aws_kinesis_firehose_delivery_stream" "raw_delivery_stream" {
  name        = "${var.parameter.account_alias}_raw-delivery_stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.iam_firehose_role_arn
    bucket_arn          = aws_s3_bucket.raw_bucket.arn
    buffer_size         = 1
    buffer_interval     = 60
    prefix              = "tb_raw/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "fherroroutputbase/!{firehose:random-string}/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"
  }

  kinesis_source_configuration {
    role_arn           = var.iam_firehose_role_arn
    kinesis_stream_arn = var.kinesis_stream_arn
  }

  tags = var.tags
}
