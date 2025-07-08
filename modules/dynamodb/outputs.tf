output "dynamodb_table_arn" {
  value = aws_dynamodb_table.visitor-count-table.arn
}

output "dynamodb_table_hashkey" {
  value = aws_dynamodb_table.visitor-count-table.hash_key
}