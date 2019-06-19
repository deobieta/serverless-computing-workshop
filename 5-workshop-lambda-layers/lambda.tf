data "archive_file" "python_lambda_with_layer" {
  type        = "zip"
  source_file = "function/main.py"
  output_path = "function/python_lambda_with_layer.zip"
}

resource "aws_s3_bucket_object" "python_lambda_with_layer" {
  bucket = "serverless-computing-workshop-${data.aws_caller_identity.current.account_id}"
  key   = "python_lambda_with_layer.zip"
  source = data.archive_file.python_lambda_with_layer.output_path
  etag   = "${filemd5(data.archive_file.python_lambda_with_layer.output_path)}"
}

resource "aws_lambda_function" "python_lambda_with_layer" {
  runtime           = "python3.7"
  timeout           = 60
  s3_bucket         = "${aws_s3_bucket_object.python_lambda_with_layer.bucket}"
  s3_key            = "${aws_s3_bucket_object.python_lambda_with_layer.key}"
  s3_object_version = "${aws_s3_bucket_object.python_lambda_with_layer.version_id}"
  function_name     = "python-lambda-with-layer"
  handler           = "main.lambda_handler"
  description       = "python layer test ${terraform.workspace}"

  layers = [
    "${aws_lambda_layer_version.python37_customfunction_layer.id}",
  ]

  role = "${aws_iam_role.python_lambda_with_layer.arn}"
}

resource "aws_iam_role" "python_lambda_with_layer" {
  name = "python_lambda_with_layer"

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
