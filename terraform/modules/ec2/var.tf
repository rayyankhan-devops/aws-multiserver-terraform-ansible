variable "instance_type" {

  description = "EC2 instance type"
  type        = string

  default = "t3.micro"
}


variable "key_name" {

  description = "Key pair name for SSH access"
  type        = string

  default = "multiserver"
}


variable "public_key_path" {

  description = "Path to the public key file for SSH access"
  type        = string

  default = "multiserver.pub"
}


variable "subnet_id" {

  description = "Subnet ID where the EC2 instances will be launched"
  type        = string

  default = "subnet-09c13d67d99648b73"
}


variable "security_group_ids" {

  description = "Security group IDs for the EC2 instances"
  type        = list(string)

  default = [
    "sg-072f1491b72423d85"
  ]
}


variable "instances" {

  description = "EC2 instances to create"

  type = map(object({
    name   = string
    role   = string
    os     = string
    ami_id = string
  }))

  default = {

    rayyan-amazon-worker = {
      name   = "rayyan-amazon-worker"
      role   = "worker"
      os     = "Amazon Linux"
      ami_id = "ami-081b0a6eac00b4f53"
    }

    rayyan-ubuntu-master = {
      name   = "rayyan-ubuntu-master"
      role   = "master"
      os     = "Ubuntu"
      ami_id = "ami-0b6d9d3d33ba97d99"
    }

    rayyan-redhat-worker = {
      name   = "rayyan-redhat-worker"
      role   = "worker"
      os     = "Red Hat"
      ami_id = "ami-00adafae70b8029d8"
    }

    rayyan-debian-worker = {
      name   = "rayyan-debian-worker"
      role   = "worker"
      os     = "Debian"
      ami_id = "ami-0b75f821522bcff85"
    }
  }
}
