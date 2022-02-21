variable "dynamodbtable" {}

variable "dynamodbhashkey" {}




resource "aws_dynamodb_table_item" "demo-data1" {
  table_name = var.dynamodbtable
  hash_key   = var.dynamodbhashkey
  item       = <<ITEM
{
  "ami_id": {"S": "ami-zxzxzxzxzxzxzxzxz"},
  "date": {"S": "2022-02-10"},
  "description": {"S": "This test AMI has been created by Gabriel Angelos "},
  "visible_via_webui": {"S": "true"}
}
ITEM
}


resource "aws_dynamodb_table_item" "demo-data2" {
  table_name = var.dynamodbtable
  hash_key   = var.dynamodbhashkey
  item       = <<ITEM
{
  "ami_id": {"S": "ami-wwwwwwwwwwwwwwwww"},
  "date": {"S": "2022-01-12"},
  "description": {"S": "This test AMI has been created by Apollo Diomedes "},
  "visible_via_webui": {"S": "true"}
}
ITEM
}


resource "aws_dynamodb_table_item" "demo-data3" {
  table_name = var.dynamodbtable
  hash_key   = var.dynamodbhashkey
  item       = <<ITEM
{
  "ami_id": {"S": "ami-xxxxxxxxxxxxxxxxx"},
  "date": {"S": "2022-02-01"},
  "description": {"S": "This test AMI has been created by Isador Akios "},
  "visible_via_webui": {"S": "true"}
}
ITEM
}



resource "aws_dynamodb_table_item" "demo-data4" {
  table_name = var.dynamodbtable
  hash_key   = var.dynamodbhashkey
  item       = <<ITEM
{
  "ami_id": {"S": "ami-yyyyyyyyyyyyyyyyyy"},
  "date": {"S": "2022-01-24"},
  "description": {"S": "This test AMI has been created by Johan Orion "},
  "visible_via_webui": {"S": "true"}
}
ITEM
}
