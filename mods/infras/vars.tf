/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                Initialize/Declare Variables
                                                     MODULE-LEVEL
  ---------------------------------------------------------|------------------------------------------------------------
*/
variable "envBuild" {
  description = "Build Environment; from ENV; E.G.: envBuild=stage"
  type        = string
}

variable "dns_zone" {
  description = "Root DNS Zone for myCo; I.E.: example.tld"
  type        = string
}

variable "project" {
  description = "Project Name: should be set to something like: eks-test"
  type        = string
}

variable "part" {
  description = "Disco partition for reuse Commercial, GovCloud, or China."
  type        = string
}

variable "officeIPAddr" {
  description = "IP address of current gateway"
  type        = string
}

variable "cluster_apps" {
  description = "The Cluster Name; I.E.: $myProject-$envBuild"
  type        = string
}

variable "host_cidr" {
  description = "CIDR block reserved for networking; E.G.: 10.100.0.0/16"
  type        = string
}

variable "builder" {
  description = "builder of the things"
  type        = string
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Kubernetes Variables
  ---------------------------------------------------------|------------------------------------------------------------
*/
variable "kubeNode_type" {
  description = "EKS worker node type, from ENV; E.G.: export TF_VAR_kubeNode_type=t3.medium"
  type        = string
}

variable "minDistSize" {
  description = "ENV Integer; initial count of distributed subnets, workers, etc; E.G.: export TF_VAR_minDistSize=3"
  type        = number
}

variable "maxDistSize" {
  description = "ENV Integer; max count of distributed EKS workers; E.G.: export TF_VAR_minDistSize=12"
  type        = number
}

variable "DATADOG_UUID" {
  description = "Preferably a v4 UUID; E.G.: cb3600cb-23bc-4d05-b841-6825e7a3daf5"
  type        = string
}
