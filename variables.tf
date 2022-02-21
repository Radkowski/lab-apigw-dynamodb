data "aws_caller_identity" "current" {}

data "aws_region" "current" {}



# main module

variable "DeploymentRegion" {
  default = "eu-west-1"
  type    = string
}

variable "DeploymentName" {
  default = "AMIRepo"
  type    = string
}

variable "DynamoDBName" {
  default = "amirepo"
  type    = string
}
