module "DYNAMODB" {
  source       = "./dynamodb"
  DynamoDBName = var.DynamoDBName
}

module "LAMBDA" {
  source         = "./lambda"
  depends_on     = [module.DYNAMODB]
  DeploymentName = var.DeploymentName
  DynamoDBName   = var.DynamoDBName
}

module "DYNAMODB-DEMO-DATA" {
  source          = "./dynamo-demo-data"
  depends_on      = [module.DYNAMODB]
  dynamodbtable   = module.DYNAMODB.dynamodb_info.name
  dynamodbhashkey = module.DYNAMODB.dynamodb_info.hash_key
}


module "API-GW" {
  source         = "./api-gateway"
  depends_on     = [module.LAMBDA, module.DYNAMODB]
  DeploymentName = var.DeploymentName
  lambda_info    = module.LAMBDA.lambda_info
}
