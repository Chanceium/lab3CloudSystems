#VPC main.tf

// Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr // The CIDR block for the VPC
  enable_dns_support   = true // Enable DNS support
  enable_dns_hostnames = true // Enable DNS hostnames
  tags                 = { Name = var.vpc_name } // Tags for the VPC
}

// Define the Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id // The ID of the VPC
  tags   = { Name = "igw-${var.vpc_name}" } // Tags for the Internet Gateway
}

// Define the Subnet
resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidrs) // The number of subnets
  vpc_id                  = aws_vpc.vpc.id // The ID of the VPC
  cidr_block              = var.subnet_cidrs[count.index] // The CIDR block for the subnet
  availability_zone       = var.availability_zones[count.index] // The availability zone
  map_public_ip_on_launch = true // Enable public IP on launch

  tags = {
    Name = "${var.vpc_name}-SN-${count.index + 1}" // Tags for the subnet
  }
}

// Define the Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id // The ID of the VPC

  route {
    cidr_block = "0.0.0.0/0" // The CIDR block
    gateway_id = aws_internet_gateway.igw.id // The ID of the Internet Gateway
  }

  tags = { Name = "${var.vpc_name}-publicRT" } // Tags for the Route Table
}

// Define the Route Table Association
resource "aws_route_table_association" "public_ra" {
  count          = length(var.subnet_cidrs) // The number of associations
  subnet_id      = aws_subnet.subnet[count.index].id // The ID of the subnet
  route_table_id = aws_route_table.public_rt.id // The ID of the Route Table
}

// Output the VPC ID
output "vpc_id" {
  value       = aws_vpc.vpc.id
}

// Output the Subnet IDs
output "subnet_ids" {
  value       = aws_subnet.subnet[*].id
}
