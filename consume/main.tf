resource "aws_glue_catalog_database" "metastore" {
  name = "hive-metastore"
}


resource "aws_glue_crawler" "cleaned_crawler" {
  database_name = aws_glue_catalog_database.metastore.name
  name          = "cleaned_crawler"
  role          = var.iam_glue_role_arn

  s3_target {
    path = "s3://${var.s3_bucket_path}"
  }
}

resource "aws_athena_workgroup" "drunk_users" {
  name = "drunk_users"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.s3_bucket_path}"      
    }
  }
}