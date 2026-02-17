data "aws_caller_identity" "current" {}

resource "aws_iam_role" "gateway_role" {
  name               = "gateway_${var.name}_role"
  assume_role_policy = file("${path.module}/../../iam_policies/api-gateway_assume_role_policy.json")
}

resource "aws_iam_policy" "api_gateway_sqs_policy" {
  name        = "gateway_${var.name}_sqs_policy"
  description = "Política de acesso ao SQS para o API Gateway"
  policy      = templatefile("${path.module}/../../iam_policies/sqs_policy.json.tpl", {
    aws_region     = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id
    sqs_queue_name = var.queue_name
  })
}

resource "aws_iam_role_policy_attachment" "gateway_role_sqs" {
  role       = aws_iam_role.gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_sqs_policy.arn
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.name
  description = var.description
  body        = templatefile("${path.module}/../../api-notifications-oas30-apigateway.yaml.tpl", {
    role_name      = aws_iam_role.gateway_role.name,
    queue_name     = var.queue_name,
    AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id,
    AWS_REGION     = var.aws_region
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  # O gatilho abaixo força a criação de um novo deployment se o arquivo mudar
  triggers = {
    redeployment = sha1(file("${path.module}/../../api-notifications-oas30-apigateway.yaml.tpl"))
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.stage_name
}
