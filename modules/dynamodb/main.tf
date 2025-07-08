# Creates a DynamoDB table for tracking visitor counts
resource "aws_dynamodb_table" "visitor-count-table" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}