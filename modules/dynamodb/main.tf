resource "aws_dynamodb_table" "visitor-count-table" {
  name         = "${var.dynamodb_table}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# resource "aws_dynamodb_table_item" "first_view" {
#   table_name = aws_dynamodb_table.visitor-count-table.name
#   hash_key   = aws_dynamodb_table.visitor-count-table.hash_key
#   item       = <<ITEM
#     {
#       "id": {"S": "0"}
#     }
#     ITEM
# }