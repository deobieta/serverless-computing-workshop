data "archive_file" "simple" {
  type        = "zip"
  source_file = "function/main.py"
  output_path = "function/simple.zip"
}

#-------------------------------------------------------------------------
# recurso aws_lambda_function para crear una función en el servicio 
# de lambda en la region us-east-2 definido en el provider.
# En este ejemplo no se utlizan todos atributos que se puede utlizar al 
# crear lambdas. Para mas información puedes visitar la página de ayuda.
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html 
#-------------------------------------------------------------------------
resource "aws_lambda_function" "simple" {
  function_name    = "simple"
  filename         = data.archive_file.simple.output_path
  source_code_hash = data.archive_file.simple.output_base64sha256

  # "main" es el nombre del archivo dentro de simple.zip (main.py) y "handler"
  # es el nombre de la función que será la "handler function" de lambda
  handler = "main.handler"
  runtime = "python3.7"

  role = aws_iam_role.simple.arn
}

output "version_number" {
<<<<<<< HEAD
  value = "${aws_lambda_function.simple.version}"
=======
  value = aws_lambda_function.simple.version
>>>>>>> 772ddd18b92e19016cb18aae8e019ec682b3dc75
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


