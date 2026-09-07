# upload local public key to aws
resource "aws_key_pair" "multiserver" {
  key_name   = var.key_name
  public_key = file("${path.root}/${var.public_key_path}")
}

# default ssh users for each linux distro
locals {
  ssh_users = {
    "Amazon Linux" = "ec2-user"
    "Ubuntu"       = "ubuntu"
    "Red Hat"      = "ec2-user"
    "Debian"       = "admin"
  }
}

# create ec2 instances from the defined map
resource "aws_instance" "ec2-nodes" {
  for_each = var.instances

  ami                         = each.value.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.multiserver.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name      = each.value.name
    Owner     = "rayyan"
    Role      = each.value.role
    OS        = each.value.os
    ManagedBy = "Terraform"
  }
}
