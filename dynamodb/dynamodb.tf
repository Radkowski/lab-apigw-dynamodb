resource "aws_dynamodb_table" "dynamodb-table" {
  #checkov:skip=CKV_AWS_119:Default AWS encryption enabled
  #checkov:skip=CKV2_AWS_16:No AS required
  name           = var.DynamoDBName
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ami_id"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "ami_id"
    type = "S"
  }
  tags = {
    Name        = "radkowski-table"
    Environment = "production"
  }
}


output "dynamodb_info" {
  value = aws_dynamodb_table.dynamodb-table
}
