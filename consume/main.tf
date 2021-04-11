resource "aws_glue_catalog_database" "metastore" {
  name = "hive-metastore"
}

resource "aws_glue_crawler" "cleaned_crawler" {
  database_name = aws_glue_catalog_database.metastore.name
  name          = "${var.parameter.account_alias}_cleaned-crawler_glue"
  role          = var.iam_glue_role_arn

  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy = "CombineCompatibleSchemas"
      }
      Version = 1
    }
  )

  s3_target {
    path = "s3://${var.s3_bucket_path}/tb_cleaned"
  }

  tags = var.tags
}


resource "aws_s3_bucket" "athena_stage" {
  bucket        = "picpay-athena-stage-bucket"
  acl           = "private"
  force_destroy = true

  tags = var.tags
}


resource "aws_athena_workgroup" "drunk_users" {
  name = "drunk_users"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_stage.bucket}"
    }
  }
  tags = var.tags
}
