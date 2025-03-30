variable "aws_region" {
  description = "Região da AWS onde a API será implantada"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Nome da API Gateway"
  type        = string
}

variable "description" {
  description = "Descrição da API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Nome do estágio da implantação"
  type        = string
}

variable "role_name" {
  description = "Nome da função IAM associada"
  type        = string
}

variable "queue_name" {
  description = "Nome da fila SQS"
  type        = string
}
