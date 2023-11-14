/*
  -------------------------------------------------------|--------------------------------------------------------------
                                                    NETWORKING
  -------------------------------------------------------|--------------------------------------------------------------
*/
# AWS: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.host_cidr # a.b.c.d/16
  enable_dns_hostnames = true
  enable_dns_support   = true
  # REF: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-sizing-ipv6
  assign_generated_ipv6_cidr_block = true # Assigns a /56 block of IPv6 IPs to the VPC

  depends_on = [
    var.builder
  ]

  tags = {
    Name        = var.project
    environment = var.envBuild
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# REQ: Create Subnets within the VPC
# AWS: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#network-requirements-subnets
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# ----------------------------------------------------------------------------------------------------------------------
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
    Name                     = var.project
    "kubernetes.io/role/elb" = 1
    "Type"                   = "Public"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# REQ: Create an Internet Gateway to enable outbound calls.
#       * There appear to be no further tagging requirements for this resource.
#       * This is what make the above subnets PUBLIC.
# AWS: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "vpc_network" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name = var.project
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# REQ: Create a Route Table with routs, one-each: IPv4 and IPv6
# AWS: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
# REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# ----------------------------------------------------------------------------------------------------------------------
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
    Name   = var.project
    "Type" = "Public"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Associate all subnets with the above Routes
# AWS: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table_association" "vpc_network" {
  count          = length(aws_subnet.vpc_network)
  subnet_id      = aws_subnet.vpc_network[count.index].id
  route_table_id = aws_route_table.vpc_network.id
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable VPC Flow Logs
# AWS: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
# HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
# ----------------------------------------------------------------------------------------------------------------------
/*
  -------------------------------------------------------|--------------------------------------------------------------
                                                    VPC Flow Logs
  -------------------------------------------------------|--------------------------------------------------------------
*/
# Create the destination log group
resource "aws_cloudwatch_log_group" "flow_logs_primary" {
  name = var.project
}

# Authorize logging to elevate permissions
data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create a role for the flow logs and attache the above policy
resource "aws_iam_role" "flow_logs_role_primary" {
  name               = "flow-logs-assume-role-${var.project}"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json
}

# ----------------------------------------------------------------------------------------------------------------------
# Create a policy that allows flow logs to write to cloud watch
data "aws_iam_policy_document" "cloudwatch_logging_primary" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

# Tie the cloudwatch_logging_primary policy to the flow-logs-assume-role
resource "aws_iam_role_policy" "cw_logging_role" {
  name   = "cloudwatch-logging-${var.project}"
  role   = aws_iam_role.flow_logs_role_primary.id
  policy = data.aws_iam_policy_document.cloudwatch_logging_primary.json
}

# ----------------------------------------------------------------------------------------------------------------------

# Configure the VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs_primary" {
  iam_role_arn    = aws_iam_role.flow_logs_role_primary.arn
  log_destination = aws_cloudwatch_log_group.flow_logs_primary.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc_network.id
}

/*
  -------------------------------------------------------|--------------------------------------------------------------
                                                       DISCO
  -------------------------------------------------------|--------------------------------------------------------------
*/
# Discover Zones
data "aws_availability_zones" "available" {
  state = "available"
}
