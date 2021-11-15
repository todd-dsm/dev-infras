/*
        Instantiate Module-Level Variables into Memory
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

variable "myDomain" {
  description = "Root DNS Zone for myCo; I.E.: example.tld; minus the trailing dot"
  type        = string
}

variable "minDistSize" {
  description = "ENV Integer; initial count of distributed subnets, workers, etc; E.G.: export TF_VAR_minDistSize=3"
  type        = number
}

variable "twoOctets" {
  default = "The first 2 octets of our CIDR block; E.G.: 10.172 of 10.172.0.0/16"
  type    = string
}

variable "host_cidr" {
  description = "CIDR block reserved for networking; E.G.: 10.172.0.0/16"
  type        = string
}

variable "builder" {
  description = "Evaluates to $USER; there must be key-pair (with the same name) in EC2 prior to apply."
}