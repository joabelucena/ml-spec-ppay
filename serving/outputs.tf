output "kinesis_stream_arn" {
  value       = aws_kinesis_stream.serving_stream.arn
  description = "ARN for kinesis stream."
}


