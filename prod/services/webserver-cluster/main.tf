provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "webservers-prod"
  server_port            = 8080
  db_remote_state_bucket = "terraform-state-bucket-355"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
}
