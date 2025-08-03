provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_template" "example" {
  name_prefix            = "${var.cluster_name}-"
  image_id               = "ami-034568121cfdea9c3"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }))

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.asg.arn]
  health_check_type   = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}


resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol  = "tcp"
    # This is a Terraform setting that allows all IP addresses to access the instance.
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Data source to fetch information about the default VPC in the AWS account.
# Useful for referencing the default VPC in other resources.
data "aws_vpc" "default" {
  default = true
}

# Data source to fetch all subnets associated with the default VPC.
# Useful for referencing subnet IDs in other resources.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Application Load Balancer to distribute traffic across instances in the Auto Scaling Group.
# Uses the subnets from the default VPC.
resource "aws_lb" "example" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# Listener for the Application Load Balancer.
# Listens on port 80 (HTTP) and returns a fixed 404 response for all requests by default.
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: return a 404 response for any request.
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"

  # allow inbound http requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow outbound http requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Target group for the Application Load Balancer.
# Used to route traffic to the instances in the Auto Scaling Group.
resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-asg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  # Health check configuration to determine instance health.
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.example.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}







