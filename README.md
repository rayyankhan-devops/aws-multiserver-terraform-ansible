# AWS Multi-Server Infrastructure with Terraform & Ansible

Automated provisioning of a heterogeneous multi-node EC2 cluster on AWS using modular Terraform, ready for multi-OS configuration management and orchestration with Ansible.

---

## 📌 Architecture Overview

This project provisions an interconnected multi-OS environment in AWS `us-east-1`, designed to simulate real-world enterprise infrastructure where nodes run diverse Linux distributions:

| Node Name | Role | OS Distribution | Default SSH User | Target Package Manager |
| :--- | :--- | :--- | :--- | :--- |
| **`rayyan-ubuntu-master`** | Control Plane / Master | Ubuntu | `ubuntu` | `apt` |
| **`rayyan-amazon-worker`** | Worker Node | Amazon Linux 2023 | `ec2-user` | `dnf` / `yum` |
| **`rayyan-redhat-worker`** | Worker Node | Red Hat Enterprise Linux | `ec2-user` | `dnf` / `yum` |
| **`rayyan-debian-worker`** | Worker Node | Debian Linux | `admin` | `apt` |

All instances are automatically tagged with `Owner = "rayyan"` and `ManagedBy = "Terraform"`.

---

## 📂 Project Structure

```text
multiserver/
├── .gitignore                      # Ignore rules for Terraform state, Ansible, & SSH keys
├── README.md                       # Project documentation
└── terraform/
    ├── terraform.tf                # Terraform & AWS provider requirements (v6.54.0)
    ├── main.tf                     # Root entry point calling EC2 module
    ├── output.tf                   # Outputs formatted IPs, users, & SSH commands
    ├── dynamic.tf                  # Dynamic configurations
    ├── multiserver                 # Private SSH key (ignored by git)
    ├── multiserver.pub             # Public SSH key (ignored by git)
    └── modules/
        └── ec2/
            ├── main.tf             # AWS Key Pair & EC2 instance resources (for_each)
            ├── var.tf              # Module variables & default instance definitions
            └── output.tf           # Module-level output mappings
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Terraform** `>= 1.5.0`
- **AWS CLI** configured (`aws configure` with valid credentials)
- **Ansible** `>= 2.14` (for configuration management)
- **OpenSSH** client

### 2. Generate SSH Key Pair (if not already created)
From the `terraform/` directory, generate an ED25519 SSH key:
```bash
ssh-keygen -t ed25519 -f multiserver -C "rayyan-multiserver"
chmod 600 multiserver
```
*(Both `multiserver` and `multiserver.pub` are safeguarded in `.gitignore` to prevent credential leakage).*

### 3. Provision with Terraform
Navigate to the `terraform/` directory:
```bash
cd terraform

# Initialize Terraform and download providers
terraform init

# Validate syntax and view planned infrastructure
terraform plan

# Apply changes to provision resources on AWS
terraform apply
```

### 4. Connect to Instances
Terraform automatically outputs connection strings for every node:
```bash
# Example SSH commands:
ssh -i multiserver ubuntu@<ubuntu-master-ip>
ssh -i multiserver ec2-user@<amazon-worker-ip>
ssh -i multiserver ec2-user@<redhat-worker-ip>
ssh -i multiserver admin@<debian-worker-ip>
```

---

## 🛠️ Ansible Integration (Next Steps)

This cluster is primed for multi-distribution Ansible playbooks.

### Inventory Setup (`ansible/inventory.ini`)
Generate an inventory using the Terraform outputs:
```ini
[master]
ubuntu-master ansible_host=<UBUNTU_IP> ansible_user=ubuntu

[workers]
amazon-worker ansible_host=<AMAZON_IP> ansible_user=ec2-user
redhat-worker ansible_host=<REDHAT_IP> ansible_user=ec2-user
debian-worker ansible_host=<DEBIAN_IP> ansible_user=admin

[all:vars]
ansible_ssh_private_key_file=../terraform/multiserver
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Ping All Nodes
```bash
ansible all -i inventory.ini -m ping
```

---

## 🔒 Security Best Practices
- **Private & Public Keys**: Excluded from version control via `.gitignore`.
- **State Files**: `.tfstate` and `.tfstate.backup` are strictly git-ignored.
- **Access Control**: Security groups and subnets can be parameterized in `terraform/modules/ec2/var.tf`.

---

## 👤 Author
**Rayyan** - DevOps & Cloud Infrastructure
