# -----------------------------------------------------------------------------
# Kubernetes Cluster for Applications
# -----------------------------------------------------------------------------
module "network" {
  source      = "./mods/network"
  host_cidr   = var.host_cidr
  minDistSize = var.minDistSize
  envBuild    = var.envBuild
  twoOctets   = var.twoOctets
  myCo        = var.myCo
  project     = var.project
  region      = var.region
  dns_zone    = var.dns_zone
  builder     = var.builder
  myDomain    = var.myDomain
}

# -----------------------------------------------------------------------------
# Quick Demos & Sanity Checks
# -----------------------------------------------------------------------------
#module "tester" {
#  source       = "./mods/test"
#  vpc_network  = module.apps_cluster.vpc_id
#  dns_zone     = var.dns_zone
#  builder      = var.builder
#  officeIPAddr = var.officeIPAddr
#}
