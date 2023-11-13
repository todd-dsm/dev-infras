/*
  -------------------------------------------------------|--------------------------------------------------------------
                                                    NETWORKING
  -------------------------------------------------------|--------------------------------------------------------------
*/
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.host_cidr # a.b.c.d/16
  enable_dns_hostnames = true
  enable_dns_support   = true
  # REF: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-sizing-ipv6
  assign_generated_ipv6_cidr_block = true # Assigns a /56 block of IPv6 IPs to the VPC

  tags = {
    Name                               = var.project
    "kubernetes.io/cluster/my-cluster" = "shared"
    partition                          = var.part
    builder                            = var.builder
  }
}
