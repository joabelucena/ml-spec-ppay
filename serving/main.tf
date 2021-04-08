resource "aws_kinesis_stream" "serving_stream" {
  name             = "punk_api_serving_stream"
  shard_count      = 1
  retention_period = 48

  tags = {
    Environment = "test"
  }
}
