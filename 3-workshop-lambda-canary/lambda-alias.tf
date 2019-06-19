#------------------------------------------------------------------------- 
# DESCOMENTA routing_config PARA DIVIDIR EL TRÁFICO ENTRE FUNCIONES!
#-------------------------------------------------------------------------
resource "aws_lambda_alias" "simple_canary" {
  name          = "alias-canary-test"
  function_name = aws_lambda_function.simple_canary.arn
  # aumentar de version
  function_version = aws_lambda_function.simple_canary.version
  depends_on = [
    aws_lambda_function.simple_canary
  ]

  /*
  routing_config {
    additional_version_weights = {
      # aqui sería 0.9 para darle 90% de trafico a la version estable
      "1" = 0.5
    }
  }
  */

}
