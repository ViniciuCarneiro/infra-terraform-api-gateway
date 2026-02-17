provider "aws" {
  region = var.aws_region
}

module "api_gateway" {
  source = "./modules/api_gateway" 

  aws_region     = var.aws_region
  name           = var.name
  description    = var.description
  stage_name     = var.stage_name
  queue_name  = var.queue_name
}
