resource "aws_dynamodb_table" "receipts_table" {
  name         = "${var.project_name}-receipts-${var.environment}"
  
  # PAY_PER_REQUEST (On-Demand) is cost-effective for unpredictable workloads like ours.
  billing_mode = "PAY_PER_REQUEST"

  # We define the primary key for the table.
  # 'receipt_id' will be a unique identifier (like a UUID) for each processed receipt.
  hash_key     = "receipt_id"

  # Define the attributes used in the key schema.
  # Only key attributes need to be defined here. Other attributes can be added on the fly.
  attribute {
    name = "receipt_id"
    type = "S" # S for String
  }

  # Enable Point-in-Time Recovery for disaster recovery and data protection.
  point_in_time_recovery {
    enabled = true
  }

  # Enforce server-side encryption using an AWS-managed key.
  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.project_name}-receipts-${var.environment}"
    }
  )
}