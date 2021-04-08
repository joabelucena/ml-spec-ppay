output "output_cleaned_bucket_path" {
  value       = aws_s3_bucket.cleaned_bucket.bucket
  description = "ARN for Firehose Role."
}
