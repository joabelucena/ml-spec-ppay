output "kinesis_stream_arn" {
  value       = aws_kinesis_stream.serving_stream.arn
  description = "ARN for kinesis stream."
}

output "kinesis_stream_name" {
  value       = aws_kinesis_stream.serving_stream.name
  description = "Kinesis Stream name."
}
