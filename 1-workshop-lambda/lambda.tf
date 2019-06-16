
#-------------------------------------------------------------------------
# S3 bucket previamente creado
# recurso aws_s3_bucket_object para indicar al servicio de lambda 
# donde deber tomar nuestro código para ser desplegado
#-------------------------------------------------------------------------
resource "aws_s3_bucket_object" "simple" {
  bucket = "serverless-computing-workshop"
  key    = "v1.0.0/simple.zip"
  source = "function/simple.zip"
  etag   = "${filemd5("function/simple.zip")}"
}

#-------------------------------------------------------------------------
# recurso aws_lambda_function para crear una función en el servicio 
# de lambda en la region us-east-2 definido en el provider.
# En este ejemplo no se utlizan todos atributos que se puede utlizar al 
# crear lambdas. Para mas información puedes visitar la página de ayuda.
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html 
#-------------------------------------------------------------------------
resource "aws_lambda_function" "simple" {
  function_name = "simple"

  # S3 bucket donde pondremos nuestro código y el servicio de lambda lo tomará
  # para ser desplegado
  s3_bucket = aws_s3_bucket_object.simple.bucket
  s3_key    = aws_s3_bucket_object.simple.key

  # "main" es el nombre del archivo dentro de simple.zip (main.py) y "handler"
  # es el nombre de la función que será la "handler function" de lambda
  handler = "main.handler"
  runtime = "python3.7"

  role = "${aws_iam_role.simple.arn}"
}

# IAM role que indica qué otros servicios de AWS la función lambda 
# puede tener acceso.
resource "aws_iam_role" "simple" {
  name = "serverless_example_lambda"

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


