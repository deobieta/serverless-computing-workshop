
data "aws_caller_identity" "current" {}

data "archive_file" "python37_customfunction_layer" {
  type        = "zip"
  source_dir  = "python-layer"
  output_path = "python-layer/python37_customfunction.zip"
}

resource "aws_s3_bucket_object" "python37_customfunction_layer" {
  bucket = "serverless-computing-workshop-${data.aws_caller_identity.current.account_id}"
  key    = "python37_customfunction_layer.zip"
  source = data.archive_file.python37_customfunction_layer.output_path
  etag   = "${filemd5(data.archive_file.python37_customfunction_layer.output_path)}"
}

resource "aws_lambda_layer_version" "python37_customfunction_layer" {
  layer_name        = "python37-customfunction-layer"
  s3_bucket         = "serverless-computing-workshop-${data.aws_caller_identity.current.account_id}"
  s3_key            = "python37_customfunction_layer.zip"
  s3_object_version = "${aws_s3_bucket_object.python37_customfunction_layer.version_id}"
}

output "aws_lambda_layer_version_python37_customfunction_layer_arn" {
  value = "${aws_lambda_layer_version.python37_customfunction_layer.arn}"
}

output "aws_lambda_layer_version_python37_customfunction_layer_id" {
  value = "${aws_lambda_layer_version.python37_customfunction_layer.id}"
}
