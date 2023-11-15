/*
                              Top-Level Outputs; Good for TESTING
*/
#output "provider_arm" {
#  value = module.clusters.oidc_provider_arn
#}

#output "partition" {
#  value = var.part
#}
#
#output "module_policy_arn" {
#  value = module.clusters.module_policy_arn
#}

#output "subnet_ids" {
#  value = module.network.subnet_ids
#}


# TEMP TESTS; DELETE LATER
#output "network_subnet_ids" {
#  value = module.network.subnet_ids
#}
#
#output "network_vpc_id" {
#  value = module.network.vpc_id
#}
#
#output "network_vpc_arn" {
#  value = module.network.vpc_arn
#}