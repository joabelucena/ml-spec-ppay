resource "aws_s3_bucket" "b" {
  bucket = "picpay-cleaned-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}