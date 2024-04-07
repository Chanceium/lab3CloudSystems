# High Avail main.tf

# Define the Launch Template
resource "aws_launch_template" "webtest" {
  name                   = "${var.launch-template}-${var.vpc_name}" // The name of the launch template
  image_id               = data.aws_ami.web-aurora.id // The ID of the AMI
  instance_type          = var.chassis // The instance type
  vpc_security_group_ids = [var.sgid] // The ID of the security group
  tag_specifications {
    resource_type = "instance" // The resource type
    tags          = { Name = "webtest-${var.vpc_name}" } // The tags for the instance
  }
  lifecycle { create_before_destroy = true } // Lifecycle policy
}

# Define the Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.webtest.id // The ID of the launch template
    version = "$Latest" // The version of the launch template
  }
  vpc_zone_identifier = var.subnetids // The ID of the VPC zone
  target_group_arns   = [aws_lb_target_group.asg-tg.arn] // The ARN of the target group
  health_check_type   = "ELB" // The type of health check
  min_size            = 2 // The minimum size of the group
  desired_capacity    = 3 // The desired capacity of the group
  max_size            = 3 // The maximum size of the group
  tag {
    key                 = "Name" // The key of the tag
    value               = "asg-${var.vpc_name}" // The value of the tag
    propagate_at_launch = true // Whether to propagate the tag at launch
  }
}

# Define the Load Balancer
resource "aws_lb" "elb-tf" {
  name               = "elb-tf-${var.vpc_name}" // The name of the load balancer
  load_balancer_type = "application" // The type of load balancer
  subnets            = var.subnetids // The subnets for the load balancer
  security_groups    = [var.sgid] // The security groups for the load balancer
}

# Define the Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb-tf.arn // The ARN of the load balancer
  port              = 80 // The port for the listener
  protocol          = "HTTP" // The protocol for the listener
  default_action {
    type = "fixed-response" // The type of action
    fixed_response {
      content_type = "text/plain" // The content type of the response
      message_body = "200, OK" // The body of the response
      status_code  = 200 // The status code of the response
    }
  }
}

# Define the Target Group
resource "aws_lb_target_group" "asg-tg" {
  name     = "asg-tg-${var.vpc_name}" // The name of the target group
  port     = 80 // The port for the target group
  protocol = "HTTP" // The protocol for the target group
  vpc_id   = var.vpcid // The ID of the VPC
  health_check {
    path                = "/" // The path for the health check
    protocol            = "HTTP" // The protocol for the health check
    matcher             = "200" // The matcher for the health check
    interval            = 15 // The interval for the health check
    timeout             = 3 // The timeout for the health check
    healthy_threshold   = 2 // The healthy threshold for the health check
    unhealthy_threshold = 2 // The unhealthy threshold for the health check
  }
}

# Define the Listener Rule
resource "aws_lb_listener_rule" "asg-listen" {
  listener_arn = aws_lb_listener.http.arn // The ARN of the listener
  priority     = 100 // The priority of the rule
  condition {
    path_pattern {
      values = ["*"] // The values for the path pattern
    }
  }
  action {
    type             = "forward" // The type of action
    target_group_arn = aws_lb_target_group.asg-tg.arn // The ARN of the target group
  }
}

# Output the DNS name of the Load Balancer
output "alb_dns_name" {
  value       = aws_lb.elb-tf.dns_name
}
