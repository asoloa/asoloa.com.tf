# IAM role for Lambda execution
resource "aws_iam_role" "assume_role" {
  name = "lambda_assume_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Instead of using DynamoDBFullAccess, only allow the required actions on the target table
resource "aws_iam_policy" "dynamodb_get_put_item" {
  name = "dynamodb_get_put_item"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      Effect   = "Allow"
      Resource = var.dynamodb_table_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  # ERROR:
  # The "for_each" set includes values derived from resource attributes that cannot be determined until apply,
  # and so Terraform cannot determine the full set of keys that will identify the instances of this resource
  # When working with unknown values in for_each, it's better to use a **map** value where the keys
  # are defined statically in your configuration and where only the values contain apply-time results.
  # for_each = toset([
  #   "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  #   aws_iam_policy.dynamodb_get_put_item.arn
  # ])

  for_each = {
    basic_role    = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    dynamodb_perm = aws_iam_policy.dynamodb_get_put_item.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.assume_role.name
}

# Package the Lambda function code
data "archive_file" "lambda_func_zip" {
  type        = "zip"
  source_file = "${path.module}/src/${var.script_file}"
  output_path = "${path.module}/src/${replace(var.script_file, split(".", var.script_file)[1], "zip")}"
}

# Lambda function
resource "aws_lambda_function" "lambda_func" {
  filename         = data.archive_file.lambda_func_zip.output_path
  function_name    = "${replace(var.domain_name, ".", "_")}-views_counter"
  role             = aws_iam_role.assume_role.arn
  handler          = "${split(".", var.script_file)[0]}.${var.lambda_handler}"
  source_code_hash = data.archive_file.lambda_func_zip.output_base64sha256

  runtime = var.runtime
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      DYNAMODB_TABLE_PK   = var.dynamodb_table_hashkey
      DYNAMODB_TABLE_ITEM = "view-count"
    }
  }
}

resource "aws_lambda_function_url" "lambda_func_url" {
  function_name      = aws_lambda_function.lambda_func.function_name
  authorization_type = "NONE"
  invoke_mode        = "BUFFERED"
  cors {
    allow_credentials = false
    allow_origins     = ["*"]
  }
}

output "lambda_func_name" {
  value = aws_lambda_function.lambda_func.function_name
}

output "lambda_func_invoke_arn" {
  value = aws_lambda_function.lambda_func.invoke_arn
}