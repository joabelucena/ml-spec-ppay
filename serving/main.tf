resource "aws_kinesis_stream" "serving_stream" {
  name             = "${var.parameter.account_alias}_punk-data-serving_stream"
  shard_count      = 1
  retention_period = 48

  tags = var.tags
}
