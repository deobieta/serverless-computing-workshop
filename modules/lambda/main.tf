data "archive_file" "this" {
  type        = "zip"
  source_file = "${path.cwd}/${var.source_file}"
  output_path = "this.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  handler     = "main.handler"
  memory_size = 128
  timeout     = 5
  runtime     = var.runtime

  role = aws_iam_role.this.arn
}

resource "aws_iam_role" "this" {
  name = var.name

  assume_role_policy = <<EOF
{
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
}
EOF
}
