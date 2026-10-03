locals {
  all_instances = merge(aws_instance.standard, aws_instance.protected)
}

output "instance_ids" {
  description = "Map of instance logical name to AWS instance ID"
  value       = { for k, v in local.all_instances : k => v.id }
}

output "private_ips" {
  description = "Map of instance logical name to assigned private IP"
  value       = { for k, v in local.all_instances : k => v.private_ip }
}
