# AWS Multi-Server Infrastructure with Terraform & Ansible

Automated provisioning of a heterogeneous multi-node EC2 cluster on AWS using modular Terraform, ready for multi-OS configuration management and orchestration with Ansible.

![AWS Multi-Server Infrastructure Architecture](assets/architecture-overview.jpg)

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
├── .gitignore                      # Excludes state, SSH keys, & live hosts.ini
├── README.md                       # Project documentation
├── assets/
│   └── architecture-overview.jpg   # Architecture & project banner graphic
├── ansible/
│   ├── ansible.cfg                 # Auto-detected Ansible configuration
│   ├── default.cfg                 # Default configuration backup/reference
│   ├── inventories/
│   │   ├── hosts.ini               # Dynamic inventory (generated on apply, git-ignored)
│   │   └── hosts.example.ini       # Committed example inventory template
│   └── playbook/
│       ├── run.yml                 # Playbook installing common tools on workers
│       └── var.yml                 # Variables file defining loop items (tools)
└── terraform/
    ├── terraform.tf                # AWS & local provider definitions
    ├── main.tf                     # Root entry point calling EC2 module
    ├── output.tf                   # Outputs formatted IPs, users, & SSH commands
    ├── dynamic.tf                  # Generates ansible/inventories/hosts.ini
    ├── multiserver                 # Private SSH key (git-ignored)
    ├── multiserver.pub             # Public SSH key (git-ignored)
    └── modules/
        └── ec2/
            ├── main.tf             # AWS Key Pair & EC2 instances (for_each)
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

### 3. Provision Infrastructure with Terraform
Navigate to the `terraform/` directory:
```bash
cd terraform

# Initialize Terraform (downloads AWS and Local providers)
terraform init

# Validate syntax and review planned infrastructure
terraform plan

# Apply changes to provision resources on AWS
terraform apply
```

Upon successful execution, Terraform will:
1. Register `multiserver.pub` with AWS EC2 in `us-east-1`.
2. Provision all 4 EC2 instances with tags and public IPs.
3. Automatically execute `dynamic.tf` to generate the Ansible inventory in `ansible/inventories/hosts.ini`.
4. Output connection details and formatted SSH commands for each node.

### 4. Connect to Instances Directly
```bash
# Example SSH commands:
ssh -i multiserver ubuntu@<ubuntu-master-ip>
ssh -i multiserver ec2-user@<amazon-worker-ip>
ssh -i multiserver ec2-user@<redhat-worker-ip>
ssh -i multiserver admin@<debian-worker-ip>
```

---

## 🛠️ Ansible Configuration & Orchestration

### Dynamic Inventory & Configuration
- **Automatic Generation**: Running `terraform apply` populates `ansible/inventories/hosts.ini` with the live public IPs.
- **Privacy Protection**: `hosts.ini` is strictly git-ignored. A template reference is provided in `ansible/inventories/hosts.example.ini`.
- **Pre-configured Defaults**: `ansible/ansible.cfg` and `ansible/default.cfg` already point to `./inventories/hosts.ini`, specify the private SSH key, and enable `sudo` escalation.

### Test Connectivity
From the `ansible/` directory, run:
```bash
cd ansible

# Ping all nodes across all distributions
ansible all -m ping

# Target only the master node
ansible master -m ping

# Target only worker nodes
ansible workers -m ping
```

### Run Configuration Playbook
Install essential tools (`git`, `curl`, `wget`, `tree`, `unzip`) across all worker nodes using loops:
```bash
ansible-playbook playbook/run.yml
```

---

## 🔒 Security Best Practices
- **Keys Protected**: Private (`multiserver`) and public (`multiserver.pub`) SSH keys are git-ignored.
- **Inventory Privacy**: Live `hosts.ini` with public IP addresses is excluded from version control.
- **State Protection**: `.tfstate` and `.tfstate.backup` files are excluded by `.gitignore`.

---

## 👤 Author
**Rayyan** - DevOps & Cloud Infrastructure
