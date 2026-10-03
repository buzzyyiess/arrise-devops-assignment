variable "aws_region" {
  type        = string
  description = "Target AWS deployment region"
  default     = "ap-south-1"
}

variable "ami_id" {
  type        = string
  description = "Standard base AMI ID for instances"
  default     = "ami-0dee22c13ea7a9a67"
}

variable "subnet_id" {
  type        = string
  description = "Target subnet ID"
  default     = "subnet-0123456789abcdef0"
}

variable "instances" {
  type = map(object({
    instance_type           = string
    root_volume_type        = string
    root_volume_size        = number
    root_iops               = optional(number)
    key_pair_name           = string
    environment             = string
    owner                   = string
    prevent_destroy_enabled = optional(bool, false)
  }))
  description = "Configuration map for all dynamically provisioned EC2 instances"
}
