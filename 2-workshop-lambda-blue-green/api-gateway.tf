#-------------------------------------------------------------------------
# recurso aws_api_gateway_rest_api para crear una API gateway REST API. 
# https://www.terraform.io/docs/providers/aws/r/api_gateway_rest_api.html
#-------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "workshop" {
  name        = "serverless-workshop"
  description = "Terraform Serverless Workshop"
}

#-------------------------------------------------------------------------
# recurso aws_api_gateway_resource para crear un recurso 
# dentro de nuestra API gateway.
# https://www.terraform.io/docs/providers/aws/r/api_gateway_resource.html
#-------------------------------------------------------------------------
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.workshop.id
  parent_id   = aws_api_gateway_rest_api.workshop.root_resource_id
  path_part   = "{proxy+}"
}

#-------------------------------------------------------------------------
# recurso aws_api_gateway_method para crear un metodo HTTP para un 
# recurso dentro de nuestra API gateway
# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
#-------------------------------------------------------------------------
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.workshop.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}


#-------------------------------------------------------------------------
# recurso aws_api_gateway_integration para crear una integración de un 
# método HTTP para la API gateway.
# Cada método en API gateway tiene una integración que especifica cual debe 
# ser la ruta de las peticiones.  
# La integración AWS_PROXY permite a API gateway comunicarse con otros 
# servicios de AWS, en este caso queremos que invoque a nuestra lambda
# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
#------------------------------------------------------------------------- 
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.workshop.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.simple_apigateway.invoke_arn
}


#-------------------------------------------------------------------------
# El recurso aws_api_gateway_resource.proxy no puede pasar una ruta vacía
# cuando queremos hablar a la raíz del API gateway y una configuración
# similar se tiene que crear para la raíz. 
#------------------------------------------------------------------------- 


resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.workshop.id
  resource_id   = aws_api_gateway_rest_api.workshop.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.workshop.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.simple_apigateway.invoke_arn
}



#-------------------------------------------------------------------------
# recurso aws_api_gateway_deployment para activar la configuarción 
# de API gateway y que el servicio exponga una URL. 
# https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
#-------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "workshop" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = aws_api_gateway_rest_api.workshop.id
  stage_name  = "test"
}

output "endpoint" {
  value = aws_api_gateway_deployment.workshop.invoke_url
}

#-------------------------------------------------------------------------
# recurso aws_lambda_permission crea el permiso para que rescursos
# externos puedan invocar la lambda. (CloudWatch Event Rule, SNS or S3)
# https://www.terraform.io/docs/providers/aws/r/lambda_permission.html
#-------------------------------------------------------------------------

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIgatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.simple_apigateway.arn
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.workshop.execution_arn}/*/*"
}


