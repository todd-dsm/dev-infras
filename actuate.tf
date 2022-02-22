# -----------------------------------------------------------------------------
# Build Kubernetes Clusters for Application Development
# -----------------------------------------------------------------------------
module "clusters" {
  source        = "./mods/infras"
  dns_zone      = var.dns_zone
  builder       = var.builder
  officeIPAddr  = var.officeIPAddr
  minDistSize   = var.minDistSize
  maxDistSize   = var.maxDistSize
  DATADOG_UUID  = var.DATADOG_UUID
  project       = var.project
  kubeNode_type = var.kubeNode_type
  envBuild      = var.envBuild
  cluster_apps  = var.cluster_apps
  host_cidr     = var.host_cidr
}

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