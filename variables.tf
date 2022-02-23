/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                     Global Variables
  ---------------------------------------------------------|------------------------------------------------------------
*/
variable "envBuild" {
  description = "Build Environment; from ENV; E.G.: envBuild=stage"
  type        = string
}

variable "myCo" {
  description = "Expands to Company Name; E.G.: my-company"
  type        = string
}

variable "project" {
  description = "Project Name: should be set to something like: eks-test"
  type        = string
}

variable "region" {
  description = "Deployment Region; from ENV; E.G.: us-west-2"
  type        = string
}

variable "dns_zone" {
  description = "Root DNS Zone for myCo; I.E.: example.tld."
  type        = string
}

variable "cluster_apps" {
  description = "The Cluster Name; I.E.: $myProject-$envBuild"
  type        = string
}

variable "myDomain" {
  description = "Root DNS Zone for myCo; I.E.: example.tld; minus the trailing dot"
  type        = string
}

variable "host_cidr" {
  description = "CIDR block reserved for networking; E.G.: 10.172.0.0/16"
  type        = string
}

variable "builder" {
  description = "Evaluates to $USER; there must be key-pair (with the same name) in EC2 prior to apply."
  type        = string
}

variable "officeIPAddr" {
  description = "The IP address of the Current (outbound) Gateway: individual A.B.C.D/32 or block A.B.C.D/29"
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

