# High Avail vars.tf

# Define the launch template variable
variable "launch-template" {
  type        = string // The type of the variable
  default     = "webtest" // The default value of the variable
}

data "aws_ami" "web-aurora" {
  owners = ["268569236870"]
  filter {
    name   = "name"
    values = ["WebImageTest"]
  }
}
# Define the chassis variable
variable "chassis" {
  default = "t2.micro" // The default value of the variable
}

# Define the security group ID variable
variable "sgid" {}

# Define the VPC ID variable
variable "vpcid" {}

# Define the subnet IDs variable
variable "subnetids" {}

# Define the VPC name variable
variable "vpc_name" {
  type = string // The type of the variable
}
