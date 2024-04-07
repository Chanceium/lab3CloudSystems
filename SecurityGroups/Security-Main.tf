#Security Groups main.tf

// Create a new AWS Security Group
resource "aws_security_group" "sgtf" {
  count  = length(var.vpc_ids)
  name   = "sgtf_${count.index}"
  vpc_id = var.vpc_ids[count.index]
  tags   = { Name = "sgtf_${count.index}" }
}

/// Allow SSH (port 22) inbound traffic from all IP addresses
resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  count = length(aws_security_group.sgtf)
  security_group_id = aws_security_group.sgtf[count.index].id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"
}

// Allow HTTP (port 80) inbound traffic from all IP addresses
resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  count = length(aws_security_group.sgtf)
  security_group_id = aws_security_group.sgtf[count.index].id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

// Allow all outbound traffic
resource "aws_security_group_rule" "allow_out" {
  count = length(aws_security_group.sgtf)
  security_group_id = aws_security_group.sgtf[count.index].id
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


// Output the ID of the created security group
output "sgtf_security_ids" {
  value = aws_security_group.sgtf[*].id
}