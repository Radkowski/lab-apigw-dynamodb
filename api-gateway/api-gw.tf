locals {
  uri_def = join("", ["arn:aws:apigateway:", data.aws_region.current.name, ":lambda:path/2015-03-31/functions/", var.lambda_info.arn, "/invocations"])
}


resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_cloudwatch_log_group" "api-gw-logs" {
  #checkov:skip=CKV_AWS_158:No encryption required
  #checkov:skip=CKV_AWS_73:No X-Ray tracing required
  name              = join("", ["/custom/", var.DeploymentName, "/API-Gateway-access"])
  retention_in_days = 365
  tags = {
    Environment = "production"
  }
}

resource "aws_api_gateway_rest_api" "amicheckerapi" {
  body = templatefile("${path.module}/api-gw.tftpl", { uri_def = local.uri_def })
  name = join("", [var.DeploymentName, "-AMI-checker"])
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_lambda_permission" "allow_APIGW" {
  statement_id  = join("", [var.DeploymentName, "-AllowExecutionFromAPIGateway"])
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_info.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = join("", ["arn:aws:execute-api:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", aws_api_gateway_rest_api.amicheckerapi.id, "/*/GET/ami-check"])
}


resource "aws_api_gateway_deployment" "amicheckerapi-deploy" {
  rest_api_id = aws_api_gateway_rest_api.amicheckerapi.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.amicheckerapi.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "amicheckerapi-stage" {
  #checkov:skip=CKV_AWS_73:No X-Ray tracing required
  #checkov:skip=CKV2_AWS_29:TBD if WAF is required
  deployment_id         = aws_api_gateway_deployment.amicheckerapi-deploy.id
  rest_api_id           = aws_api_gateway_rest_api.amicheckerapi.id
  cache_cluster_enabled = true
  cache_cluster_size    = 0.5
  stage_name            = "v1"
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-gw-logs.arn
    format          = templatefile("${path.module}/log-format.tftpl", {})
  }
}


resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.amicheckerapi.id
  stage_name  = aws_api_gateway_stage.amicheckerapi-stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}
