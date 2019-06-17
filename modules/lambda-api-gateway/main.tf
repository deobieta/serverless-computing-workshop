module "lambda" {
  source      = "../lambda/"
  name        = var.name
  runtime     = var.runtime
  source_file = var.source_file
}

module "api-gateway" {
  source        = "../api-gateway/"
  name          = var.name
  function_name = module.lambda.function_name
}

