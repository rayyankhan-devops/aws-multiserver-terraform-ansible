# ==============================================================================
# Dynamic Ansible Inventory Generator
# ==============================================================================
# Automatically populates ansible/inventories/hosts.ini with the instance names,
# public IPs, and usernames created by the EC2 module.

resource "local_file" "ansible_inventory" {
  filename = "${path.root}/../ansible/inventories/hosts.ini"

  content = <<-EOT
# Generated automatically by Terraform

[master]
%{ for inst in module.ec2.instances ~}
%{ if inst.role == "master" ~}
${inst.name} ansible_host=${inst.public_ip} ansible_user=${inst.username}
%{ endif ~}
%{ endfor ~}

[workers]
%{ for inst in module.ec2.instances ~}
%{ if inst.role == "worker" ~}
${inst.name} ansible_host=${inst.public_ip} ansible_user=${inst.username}
%{ endif ~}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file=../terraform/multiserver
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT
}
