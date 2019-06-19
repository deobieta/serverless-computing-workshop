
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "lambda" {
  bucket = "serverless-computing-workshop-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

output "workshop_bucket_name" {
  value = aws_s3_bucket.lambda.bucket
}
