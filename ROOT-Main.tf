#main-root.tf

# Define the Blue VPC module
module "vpcBlue" {
  source = "./VPC" // The source of the module
  vpc_cidr = "100.64.0.0/16" // The CIDR block for the VPC
  vpc_name = "vpcBlue" // The name of the VPC
  subnet_cidrs = ["100.64.0.0/24", "100.64.1.0/24", "100.64.2.0/24"] // The CIDR blocks for the subnets
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] // The availability zones
}

# Define the Blue High Availability module
module "HighAvailBlue" {
    source = "./HighAvail" // The source of the module
    sgid = module.SecurityGroups.sgtf_security_ids[0] // The ID of the security group
    vpcid = module.vpcBlue.vpc_id // The ID of the VPC
    subnetids = module.vpcBlue.subnet_ids // The IDs of the subnets
    vpc_name = "vpcBlue" // The name of the VPC
}

# Define the Green VPC module
module "vpcGreen" {
  source = "./VPC" // The source of the module
  vpc_cidr = "192.168.0.0/16" // The CIDR block for the VPC
  vpc_name = "vpcGreen" // The name of the VPC
  subnet_cidrs = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"] // The CIDR blocks for the subnets
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] // The availability zones
}

# Define the Green High Availability module
module "HighAvailGreen" {
    source = "./HighAvail" // The source of the module
    sgid = module.SecurityGroups.sgtf_security_ids[1] // The ID of the security group
    vpcid = module.vpcGreen.vpc_id // The ID of the VPC
    subnetids = module.vpcGreen.subnet_ids // The IDs of the subnets
    vpc_name = "vpcGreen" // The name of the VPC
}

#Define the SecurityGroups module
module "SecurityGroups" {
    source = "./SecurityGroups" // The source of the module
    vpc_ids = [module.vpcBlue.vpc_id, module.vpcGreen.vpc_id] // The VPC ids being passed into the security group.
}

output "HighAvailLoadBalancerDNS" {
    value = {
        "Green" = module.HighAvailGreen.alb_dns_name
        "Blue" = module.HighAvailBlue.alb_dns_name
    }
}
