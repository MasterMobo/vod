variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southest-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "vod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
  default     = "vod-ec2-key"
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/vod-ec2-key.pub"
}

variable "allowed_ips" {
  description = "List of IPs allowed to SSH (your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # TODO: Change this to your IP for security!
}

# variable "db_password" {
#   description = "PostgreSQL password"
#   type        = string
#   sensitive   = true
#   # You'll set this via terraform.tfvars or environment variable
# }


