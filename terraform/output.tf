# expose instance details for ssh and ansible access
output "instances" {
  description = "Public IP, SSH username, and connection details for each EC2 instance"
  value = {
    for key, inst in module.ec2.instances : key => {
      name        = inst.name
      owner       = inst.owner
      username    = inst.username
      public_ip   = inst.public_ip
      ssh_command = inst.ssh_command
    }
  }
}
