# Lesson 5: AWS Infrastructure Provisioning with Terraform

This project provisions core AWS infrastructure modules using Terraform.

## Project Structure
- `modules/s3-backend`: Creates S3 bucket with versioning and DynamoDB state lock table.
- `modules/vpc`: Creates VPC with 3 public/private subnets, Internet Gateway, and NAT Gateway.
- `modules/ecr`: Elastic Container Registry with image scan-on-push enabled.

## Deployment Steps

1. **Initialize Terraform locally:**
   ```bash
   terraform init
   ```

2. **Run Plan:**
   ```bash
   terraform plan
   ```

3. **Apply Configuration:**
   ```bash
   terraform apply
   ```

4. **Migrate State to Remote Backend (S3 + DynamoDB)**
   Ensure backend.tf is created, then run terraform init again and confirm state migration by typing yes.
   
5. **Destroy Infrastructure (optional):**
    ```bash
   terraform destroy
   ```
   