provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Local variables definition
locals {
  parameters = {
    account_alias = var.account_alias,
    account_id    = var.account_id
  }
  tags = {
    env     = "dev",
    project = "picpay-audition"
  }
}

# Creates all necessary IAM roles
module "authorization" {
  source    = "./authorization"
  parameter = local.parameters
  tags      = merge(local.tags, { layer = "authorization" })
}

# Creates ingestion layer: Kinesis Stream
module "serving" {
  source    = "./serving"
  parameter = local.parameters
  tags      = merge(local.tags, { layer = "serving" })

  depends_on = [
    module.authorization
  ]
}

# Creates ingestion layer: CloudWatch Event and Lambda
module "ingestion" {
  source              = "./ingestion"
  iam_lambda_role_arn = module.authorization.output_iam_lambda_role
  kinesis_stream_name = module.serving.kinesis_stream_name
  parameter           = local.parameters
  tags                = merge(local.tags, { layer = "ingestion" })

  depends_on = [
    module.authorization,
    module.serving
  ]
}

# Creates raw delivery layer: Kinesis Firehose and S3 bucket
module "raw_delivery" {
  source                = "./etl/raw"
  kinesis_stream_arn    = module.serving.kinesis_stream_arn
  iam_firehose_role_arn = module.authorization.output_iam_firehose_role
  parameter             = local.parameters
  tags                  = merge(local.tags, { layer = "raw_delivery" })

  depends_on = [
    module.authorization,
    module.serving
  ]
}

# Creates cleaned delivery layer: Kinesis Firehose, Transformation Lambda and S3 bucket
module "cleaned_delivery" {
  source                = "./etl/cleaned"
  kinesis_stream_arn    = module.serving.kinesis_stream_arn
  iam_firehose_role_arn = module.authorization.output_iam_firehose_role
  iam_lambda_role_arn   = module.authorization.output_iam_lambda_role
  parameter             = local.parameters
  tags                  = merge(local.tags, { layer = "cleaned_delivery" })

  depends_on = [
    module.authorization,
    module.serving
  ]
}

# Creates consume layer: Glue Crawler, Athena workgroup and S3 bucket
module "consume" {
  source            = "./consume"
  iam_glue_role_arn = module.authorization.output_iam_glue_role
  s3_bucket_path    = module.cleaned_delivery.output_cleaned_bucket_path
  parameter         = local.parameters
  tags              = merge(local.tags, { layer = "consume" })

  depends_on = [
    module.authorization,
    module.cleaned_delivery
  ]
}