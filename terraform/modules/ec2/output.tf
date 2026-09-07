output "instances" {
  description = "Public IP and SSH username for each created instance"
  value = {
    for k, instance in aws_instance.ec2-nodes : k => {
      name        = instance.tags["Name"]
      owner       = instance.tags["Owner"]
      role        = instance.tags["Role"]
      os          = instance.tags["OS"]
      public_ip   = instance.public_ip
      username    = lookup(local.ssh_users, instance.tags["OS"], "ec2-user")
      ssh_command = "ssh -i ${var.key_name} ${lookup(local.ssh_users, instance.tags["OS"], "ec2-user")}@${instance.public_ip}"
    }
  }
}
