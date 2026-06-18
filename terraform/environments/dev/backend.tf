# Configures remote state storage in S3 and state locking with DynamoDB.
# Ensures that state file is encrypted at rest and supports concurrent execution locks.

terraform {
  backend "s3" {
    bucket         = "shopwave-tfstate-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "shopwave-tflocks"
    encrypt        = true
  }
}