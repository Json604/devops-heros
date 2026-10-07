variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "cluster_name" {
  type    = string
  default = "kartikey-helpdesk"
}
variable "kubernetes_version" {
  type    = string
  default = "1.35"
}
variable "admin_cidr" {
  type        = string
  description = "Public IPv4 of administrator or runner, restricted to /32."
  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Use a single IPv4 address with /32."
  }
}
