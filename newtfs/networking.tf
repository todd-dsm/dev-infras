/*
  ----------------------------------------------------------------------------------------------------------------------
                                                       NETWORKING
  ----------------------------------------------------------------------------------------------------------------------
*/
# THE VPC
#resource "aws_vpc" "vpc_network" {
#  cidr_block           = var.host_cidr # a.b.c.d/16
#  enable_dns_hostnames = true
#  enable_dns_support   = true
#  # REF: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-sizing-ipv6
#  assign_generated_ipv6_cidr_block = true # Assigns a /56 block of IPv6 IPs to the VPC
#
#  tags = {
#    Name                               = var.project
#    "kubernetes.io/cluster/my-cluster" = "shared"
#  }
#}

# Create Subnets within the VPC
# n = count = var.minDistSize (needs to be </= 4)
# REQ: Create n number of /18 IPv4 subnets
# REQ: Create n number of /64 IPv6 subnets
resource "aws_subnet" "vpc_network" {
  vpc_id                          = aws_vpc.vpc_network.id
  count                           = var.minDistSize
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  # Get AZs from Region
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # TF Function: cidrsubnet(prefix, newbits, netnum)
  # REF: https://www.terraform.io/docs/language/functions/cidrsubnet.html
  cidr_block      = cidrsubnet(var.host_cidr, 2, count.index)
  ipv6_cidr_block = cidrsubnet(aws_vpc.vpc_network.ipv6_cidr_block, 8, count.index)

  tags = {
    Name                               = var.project
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}

# REQ: Create an Internet Gateway we can make outbound calls
# REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "vpc_network" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name                               = var.project
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}

# REQ: Create a Route Table with routs, one-each: IPv4 and IPv6
# REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "vpc_network" {
  vpc_id = aws_vpc.vpc_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.vpc_network.id
  }

  tags = {
    Name                               = var.project
    "kubernetes.io/cluster/my-cluster" = "shared"
  }
}

# Associate all subnets with the above Routes
# REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "vpc_network" {
  count          = length(aws_subnet.vpc_network)
  subnet_id      = aws_subnet.vpc_network[count.index].id
  route_table_id = aws_route_table.vpc_network.id
}

/*
  ----------------------------------------------------------------------------------------------------------------------
                                                          DISCO
  ----------------------------------------------------------------------------------------------------------------------
*/
# Discover Zones
data "aws_availability_zones" "available" {
  state = "available"
}
