variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "bucket_name" {
  type    = string
  default = "kartikey-24bcs10121-cloud-lab"
}
variable "allowed_http_cidr" {
  type        = string
  description = "Your public IPv4 address followed by /32."
  validation {
    condition     = can(cidrnetmask(var.allowed_http_cidr)) && endswith(var.allowed_http_cidr, "/32")
    error_message = "Use a single IPv4 address with /32."
  }
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
