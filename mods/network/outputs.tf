/*
  ----------------------------------------------------------------------------------------------------------------------
                                                         OUTPUTS
  ----------------------------------------------------------------------------------------------------------------------
*/
output "subnet_ids" {
  value = aws_subnet.vpc_network[*].id
}

output "vpc_id" {
  value = aws_vpc.vpc_network.id
}

output "vpc_arn" {
  value = aws_vpc.vpc_network.arn
}
