resource "aws_iam_role" "lambda-role" {
  name = join("", [var.DeploymentName, "-db-checker-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = join("", [var.DeploymentName, "-db-checker-role-policy"])

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["dynamodb:GetItem"],
          "Resource" : join("", ["arn:aws:dynamodb:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":table/", var.DynamoDBName])
        },
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : join("", ["arn:aws:logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":*"])
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            join("", ["arn:aws:logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", "log-group:/aws/lambda/", var.DeploymentName, "-db-checker:*"])
          ]
        }
      ]
    })
  }
}


resource "aws_lambda_function" "db-checker" {
  #checkov:skip=CKV_AWS_50:No X-ray tracing for lambda required
  #checkov:skip=CKV_AWS_117:No VPC access required
  #checkov:skip=CKV_AWS_116:No DLQ required
  #checkov:skip=CKV_AWS_173:Default AWS lambda encryption enabled
  #checkov:skip=CKV_AWS_115:No limit for concurrent executions required 
  function_name    = join("", [var.DeploymentName, "-db-checker"])
  role             = aws_iam_role.lambda-role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = "./zip/lambda.zip"
  source_code_hash = filebase64sha256("./zip/lambda.zip")
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      DYNAMO_TABLE = var.DynamoDBName
    }
  }
}


output "lambda_info" {
  value = aws_lambda_function.db-checker
}
