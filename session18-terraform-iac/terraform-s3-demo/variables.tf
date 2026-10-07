variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name. Append your account ID if already taken."
  default     = "kartikey-24bcs10121-devops-lab"
}
