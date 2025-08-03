# variables.tf for webserver-cluster
# Define your variables here 

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
