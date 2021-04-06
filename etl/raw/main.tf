resource "aws_s3_bucket" "b" {
  bucket = "picpay-raw-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}