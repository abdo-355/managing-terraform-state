# Learning Terraform with AWS: S3 State Management

This is a simple project to help me learn how to use Terraform with AWS for secure state management.

## What does it do?

- Creates an S3 bucket to securely store Terraform state files
- Enables versioning to keep a history of state changes
- Applies server-side encryption to protect state data
- Blocks all public access to the S3 bucket
- Configures the S3 backend for Terraform with native locking

## Main AWS Resources Used

- `aws_s3_bucket`: Creates the S3 bucket for state storage
- `aws_s3_bucket_versioning`: Enables versioning on the bucket
- `aws_s3_bucket_server_side_encryption_configuration`: Applies default encryption (AES256)
- `aws_s3_bucket_public_access_block`: Ensures the bucket is not publicly accessible
