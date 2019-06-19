module "lambda-api-gateway" {
  source      = "../modules/lambda-api-gateway/"
  name        = "simple-blackbox"
  runtime     = "python3.6"
  source_file = "function/main.py"
}

output "api_gateway_invoke_url" {
  value = module.lambda-api-gateway.invoke_url
}
