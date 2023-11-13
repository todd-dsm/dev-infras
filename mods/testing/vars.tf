/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Module Variables
  ---------------------------------------------------------|------------------------------------------------------------
*/
variable "project" {
  description = "Project Name: should be set to something like: eks-test"
  type        = string
}

variable "host_cidr" {
  description = "CIDR block reserved for networking; E.G.: 10.172.0.0/16"
  type        = string
}

variable "part" {
  description = "Disco partition for reuse Commercial, GovCloud, or China."
  type        = string
  default     = ""
}

variable "builder" {
  description = "The IAM Account name of the calling user; E.G.: tthomas"
  type        = string
}