/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                       Discovery
  Some common discovery stuff for the module.
  ---------------------------------------------------------|------------------------------------------------------------
*/
# discover the calling user; the resulting account is the builder =
data "aws_caller_identity" "found" {}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                       Partition
  Automatically discover which partition we're in:
    * Commercial: aws
    * China:      aws-cn
    * GovCloud:   aws-us-gov
  AWS: https://docs.aws.amazon.com/whitepapers/latest/aws-fault-isolation-boundaries/partitions.html
  HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition
  ---------------------------------------------------------|------------------------------------------------------------
*/
data "aws_partition" "found" {}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                        Locals
  Make the assignment for variable distribution.
  ---------------------------------------------------------|------------------------------------------------------------
*/
locals {
  builder    = regex("arn:${local.part}:iam::\\d+:user/(.*)", data.aws_caller_identity.found.arn)[0]
  part       = data.aws_partition.found.partition
  dns_suffix = data.aws_partition.found.dns_suffix
}



output "iam_user" {
  value = local.builder
}

output "partition" {
  value = local.part
}

output "dns_suffix" {
  value = local.dns_suffix
}