# Criacao do bucket
resource "aws_s3_bucket" "cleaned_bucket" {
  bucket = "picpay-cleaned-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_kinesis_firehose_delivery_stream" "cleaned_delivery_stream" {
  name        = "cleaned_delivery_stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.iam_firehose_role_arn
    bucket_arn          = aws_s3_bucket.cleaned_bucket.arn
  }

  kinesis_source_configuration {
    role_arn            = var.iam_firehose_role_arn
    kinesis_stream_arn  = var.kinesis_stream_arn
  }
}