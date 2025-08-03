provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  engine_version      = "8.0.41"      # keep the exact version you want
  instance_class      = "db.t3.micro" # or db.t4g.micro (ARM), db.m5.large, etc.
  allocated_storage   = 20
  db_name             = "example_database"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}


terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-355"
    key          = "prod/data-stores/mysql/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
