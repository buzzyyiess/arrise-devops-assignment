resource "aws_key_pair" "keys" {
  for_each   = toset([for k, v in var.instances : v.key_pair_name])
  key_name   = each.value
  public_key = file("${path.module}/keys/${each.value}.pub")
}

# Standard instances (destroy-allowed)
resource "aws_instance" "standard" {
  for_each = {
    for k, v in var.instances : k => v if !coalesce(v.prevent_destroy_enabled, false)
  }

  ami           = var.ami_id
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.keys[each.value.key_pair_name].key_name
  subnet_id     = var.subnet_id

  root_block_device {
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size
    iops                  = contains(["io1", "io2"], each.value.root_volume_type) ? each.value.root_iops : null
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
    ManagedBy   = "Terraform"
  }
}

# Protected instance (lifecycle prevent_destroy)
resource "aws_instance" "protected" {
  for_each = {
    for k, v in var.instances : k => v if coalesce(v.prevent_destroy_enabled, false)
  }

  ami           = var.ami_id
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.keys[each.value.key_pair_name].key_name
  subnet_id     = var.subnet_id

  root_block_device {
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size
    iops                  = contains(["io1", "io2"], each.value.root_volume_type) ? each.value.root_iops : null
    delete_on_termination = false
    encrypted             = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
    ManagedBy   = "Terraform"
  }
}
