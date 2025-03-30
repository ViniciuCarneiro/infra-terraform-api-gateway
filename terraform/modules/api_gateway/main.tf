data "aws_caller_identity" "current" {}


# Cria o API Gateway a partir do arquivo OpenAPI (YAML)
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.name
  description = var.description
  body        = templatefile("${path.module}/../../api-notifications-oas30-apigateway.yaml.tpl", {
    role_name         = var.role_name
    queue_name        = var.queue_name
    AWS_ACCOUNT_ID    = data.aws_caller_identity.current.account_id
    AWS_REGION        = var.aws_region
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Realiza a implantação (deployment) da API
resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  # O gatilho abaixo força a criação de um novo deployment se o arquivo mudar
  triggers = {
    redeployment = sha1(file("${path.module}/../../api-notifications-oas30-apigateway.yaml.tpl"))
  }
}

# Cria o estágio da API
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.stage_name
}
