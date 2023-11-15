# -----------------------------------------------------------------------------
# Build Kubernetes Clusters for Application Development
# -----------------------------------------------------------------------------
module "eks" {
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
  dns_suffix    = local.dns_suffix
  builder       = local.builder
}

# -----------------------------------------------------------------------------
# Enable EKS Addons
# -----------------------------------------------------------------------------
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.12"

  cluster_name      = var.cluster_apps
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  enable_aws_load_balancer_controller    = true
  enable_cluster_proportional_autoscaler = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  #enable_karpenter                       = true
  #enable_kube_prometheus_stack           = true
  #enable_cert_manager                    = true
  #cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
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
#}