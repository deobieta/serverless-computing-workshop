
data "archive_file" "simple_canary" {
  type        = "zip"
  source_file = "function/main.py"
  output_path = "function/simple_canary.zip"
}


data "aws_caller_identity" "current" {}

#-------------------------------------------------------------------------
# S3 bucket previamente creado
# recurso aws_s3_bucket_object para indicar al servicio de lambda 
# donde deber tomar nuestro código para ser desplegado
#-------------------------------------------------------------------------
resource "aws_s3_bucket_object" "simple_canary" {
  bucket = "serverless-computing-workshop-${data.aws_caller_identity.current.account_id}"
  key    = "simple_canary.zip"
  source = data.archive_file.simple_canary.output_path
  etag   = "${filemd5(data.archive_file.simple_canary.output_path)}"
}


#-------------------------------------------------------------------------
# recurso aws_lambda_function para crear una función en el servicio 
# de lambda en la region us-east-2 definido en el provider.
# En este ejemplo no se utlizan todos atributos que se puede utlizar al 
# crear lambdas. Para mas información puedes visitar la página de ayuda.
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html 
#-------------------------------------------------------------------------
resource "aws_lambda_function" "simple_canary" {
  function_name = "simple-canary-10"

  # incrementa la version para canary release
  publish = true

  # S3 bucket donde pondremos nuestro código y el servicio de lambda lo tomará
  # para ser desplegado
  s3_bucket         = "${aws_s3_bucket_object.simple_canary.bucket}"
  s3_key            = "${aws_s3_bucket_object.simple_canary.key}"
  s3_object_version = "${aws_s3_bucket_object.simple_canary.version_id}"


  # "main" es el nombre del archivo dentro de simple_canary.zip (main.py) y "handler"
  # es el nombre de la función que será la "handler function" de lambda
  handler = "main.handler"
  runtime = "python3.7"

  role = "${aws_iam_role.simple_canary.arn}"
}

# IAM role que indica qué otros servicios de AWS la función lambda 
# puede tener acceso.
resource "aws_iam_role" "simple_canary" {
  name = "simple_canary_lambda"

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
