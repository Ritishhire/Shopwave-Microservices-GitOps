output "s3_bucket_name" {
  description = "The name of the S3 bucket created for remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}