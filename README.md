# Managing Terraform State with AWS S3 (Modular Structure)

This project demonstrates best practices for managing Terraform state securely using AWS S3, with a modular and scalable project structure.

## Project Structure

```
backend.tf                # Contains only the backend configuration for remote state (must remain at root)
global/
  s3/
    main.tf               # S3 bucket and related resources for Terraform state
    outputs.tf            # Outputs for the S3 state bucket
stage/
  services/
    webserver-cluster/
      main.tf             # Placeholder for webserver resources
      variables.tf        # Placeholder for variables
      outputs.tf          # Placeholder for outputs
s3.tfbackend              # S3 backend configuration file for initializing state
```

## What does it do?

- **Creates an S3 bucket** to securely store Terraform state files
- **Enables versioning** to keep a history of state changes
- **Applies server-side encryption** to protect state data
- **Blocks all public access** to the S3 bucket
- **Uses a modular structure** for scalable infrastructure management
- **Configures the S3 backend** for Terraform with native locking

## How to Use

1. **Initialize the backend:**

   - The `backend.tf` file at the root configures the S3 backend. Do not move this file; Terraform requires backend configuration at the root.
   - The `s3.tfbackend` file contains backend settings for initializing state.
   - Run:
     ```sh
     terraform init -backend-config=s3.tfbackend
     ```

2. **Organize your resources:**

   - All infrastructure resources are organized in subfolders (e.g., `global/s3/`, `stage/services/webserver-cluster/`).
   - Add or modify resources in these subfolders as needed.

3. **Apply your configuration:**
   - Run Terraform commands from the project root:
     ```sh
     terraform plan
     terraform apply
     ```

## Main AWS Resources Used

- `aws_s3_bucket`: Creates the S3 bucket for state storage
- `aws_s3_bucket_versioning`: Enables versioning on the bucket
- `aws_s3_bucket_server_side_encryption_configuration`: Applies default encryption (AES256)
- `aws_s3_bucket_public_access_block`: Ensures the bucket is not publicly accessible

## Notes

- The backend configuration **must remain at the root** for Terraform to use remote state.
- All other logic/resources can be organized in subfolders for clarity and scalability.
