# outputs.tf for webserver-cluster
# Define your outputs here 

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}
