# DynamoDB Table for Visitor Counter

resource "aws_dynamodb_table" "visitors" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"  # On-demand pricing (cost-effective for low traffic)
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
  }
}

# Initialize the counter with a starting value
resource "aws_dynamodb_table_item" "visitor_count" {
  table_name = aws_dynamodb_table.visitors.name
  hash_key   = aws_dynamodb_table.visitors.hash_key

  item = jsonencode({
    id = {
      S = "visitor_count"
    }
    count = {
      N = "0"
    }
  })

  lifecycle {
    ignore_changes = [item]  # Don't reset counter on terraform apply
  }
}
