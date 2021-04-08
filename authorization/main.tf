# Role for Kinesis Data Firehose
resource "aws_iam_role" "iam_firehose_role" {
  name = "iam_firehose_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "firehose.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonKinesisFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

# Role for Lambda
resource "aws_iam_role" "iam_lambda_role" {
  name = "iam_lambda_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
  ]
}
