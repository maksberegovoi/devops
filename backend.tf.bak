terraform {
  backend "s3" {
    bucket         = "mb-tf-state-164253013547"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}