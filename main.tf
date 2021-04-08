provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

module "authorization" {
  source = "./authorization"
}

module "ingestion" {
  source = "./ingestion"
  iam_lambda_role_arn = module.authorization.output_iam_lambda_role
}

module "serving" {
  source = "./serving"
}

module "raw_delivery" {
  source = "./etl/raw"
  kinesis_stream_arn = module.serving.kinesis_stream_arn
  iam_firehose_role_arn = module.authorization.output_iam_firehose_role
}

module "cleaned_delivery" {
  source = "./etl/cleaned"
  kinesis_stream_arn = module.serving.kinesis_stream_arn
  iam_firehose_role_arn = module.authorization.output_iam_firehose_role
  iam_lambda_role_arn = module.authorization.output_iam_lambda_role
}


module "consume" {
  source = "./consume"
  iam_glue_role_arn = module.authorization.output_iam_glue_role
  s3_bucket_path = module.cleaned_delivery.output_cleaned_bucket_path
}