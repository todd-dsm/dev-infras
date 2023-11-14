# -----------------------------------------------------------------------------
# Build Kubernetes Clusters for Application Development
# -----------------------------------------------------------------------------
module "clusters" {
  source        = "./mods/infras"
  dns_zone      = var.dns_zone
  minDistSize   = var.minDistSize
  maxDistSize   = var.maxDistSize
  DATADOG_UUID  = var.DATADOG_UUID
  project       = var.project
  kubeNode_type = var.kubeNode_type
  envBuild      = var.envBuild
  cluster_apps  = var.cluster_apps
  host_cidr     = var.host_cidr
  zone_private  = var.zone_private
  officeIPAddr  = var.officeIPAddr
  part          = local.part
  builder       = local.builder
}

# -----------------------------------------------------------------------------
# Testing: vpc config for quick tf testing
# -----------------------------------------------------------------------------
#module "testing" {
#  source    = "./mods/testing"
#  host_cidr = var.host_cidr
#  project   = var.project
#  part      = local.part
#  builder   = var.builder
#}

# -----------------------------------------------------------------------------
# Networking: Project-level
# -----------------------------------------------------------------------------
#module "network" {
#  source      = "./mods/network"
#  host_cidr   = var.host_cidr
#  minDistSize = var.minDistSize
#  envBuild    = var.envBuild
#  myCo        = var.myCo
#  project     = var.project
#  region      = var.region
#  dns_zone    = var.dns_zone
#  builder     = var.builder
#  myDomain    = var.myDomain
#}