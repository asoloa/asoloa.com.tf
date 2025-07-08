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

# # This block will also reset the view-count when executing `terraform apply` again.
# resource "aws_dynamodb_table_item" "set_pk" {
#   table_name = aws_dynamodb_table.visitor-count-table.name
#   hash_key   = aws_dynamodb_table.visitor-count-table.hash_key
#   item       = <<ITEM
#     {
#         "${aws_dynamodb_table.visitor-count-table.hash_key}": {"S": "0"}
#     }
#     ITEM
# }

# Create the first and only primary key of our table.
# Using null_resource ensures that the view-count won't reset when executing `terraform apply` again.
resource "null_resource" "set_pk" {
  provisioner "local-exec" {
    command = <<EOT
      aws dynamodb put-item \
        --table-name "${aws_dynamodb_table.visitor-count-table.name}" \
        --item '{"${aws_dynamodb_table.visitor-count-table.hash_key}": {"S": "0"}}' \
        --region "${aws_dynamodb_table.visitor-count-table.region}"
    EOT
  }
}