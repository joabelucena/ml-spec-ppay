# Criacao do bucket
resource "aws_s3_bucket" "cleaned_bucket" {
  bucket        = "picpay-cleaned-bucket"
  acl           = "private"
  force_destroy = true

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
    buffer_size         = 1
    buffer_interval     = 60
    prefix              = "tb_cleaned/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "fherroroutputbase/!{firehose:random-string}/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_cleaning.arn}:$LATEST"
        }
      }
    }
  }

  kinesis_source_configuration {
    role_arn           = var.iam_firehose_role_arn
    kinesis_stream_arn = var.kinesis_stream_arn
  }

}

data "archive_file" "source_file" {
  type        = "zip"
  source_file = "${path.module}/resources/lambda_function.py"
  output_path = "${path.module}/resources/lambda_function.zip"
}

resource "aws_lambda_function" "lambda_cleaning" {
  filename      = data.archive_file.source_file.output_path
  function_name = "lambda_cleaning"
  role          = var.iam_lambda_role_arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(data.archive_file.source_file.output_path)

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
