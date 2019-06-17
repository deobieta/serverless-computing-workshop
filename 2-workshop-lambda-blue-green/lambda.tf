
variable "app_version" {
  default = "1"
}

#-------------------------------------------------------------------------
# recurso aws_lambda_function para crear una función en el servicio 
# de lambda en la region us-east-2 definido en el provider.
# En este ejemplo no se utlizan todos atributos que se puede utlizar al 
# crear lambdas. Para mas información puedes visitar la página de ayuda.
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html 
#-------------------------------------------------------------------------
resource "aws_lambda_function" "simple_apigateway" {
  function_name = "simple-apigateway"

  # S3 bucket donde pondremos nuestro código y el servicio de lambda lo tomará
  # para ser desplegado
  s3_bucket = "serverless-computing-workshop"
  s3_key    = "v${var.app_version}/simple.zip"

  # "main" es el nombre del archivo dentro de simple_apigateway.zip (main.py) y "handler"
  # es el nombre de la función que será la "handler function" de lambda
  handler = "main.handler"
  runtime = "python3.7"

  role = "${aws_iam_role.simple_apigateway.arn}"
}

# IAM role que indica qué otros servicios de AWS la función lambda 
# puede tener acceso.
resource "aws_iam_role" "simple_apigateway" {
  name = "simple_apigateway_lambda"

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


