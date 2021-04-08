output "output_iam_firehose_role" {
  value       = aws_iam_role.iam_firehose_role.arn
  description = "ARN for Firehose Role."
}

output "output_iam_lambda_role" {
  value       = aws_iam_role.iam_lambda_role.arn
  description = "ARN for Lambda Role."
}
