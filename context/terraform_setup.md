Prerequisites and Terraform setup for deploying to EC2:

## Prerequisites

### 1. AWS Account Setup

- Create an AWS account
- Create an IAM user with programmatic access (not root)
- Attach policies: `AmazonEC2FullAccess`, `AmazonVPCFullAccess`, `AmazonS3FullAccess` (for later)

### 2. Install Tools

**Terraform:**

```bash
# On Debian/Ubuntu
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify
terraform version
```

**AWS CLI:**

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure
aws configure
# Enter: Access Key ID, Secret Access Key, Region (e.g., us-east-1), Output format (json)
```

### 3. Create SSH Key Pair

```bash
# Create key pair for EC2 access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vod-ec2-key -N ""

# This creates:
# ~/.ssh/vod-ec2-key (private key - keep secret!)
# ~/.ssh/vod-ec2-key.pub (public key - we'll upload to AWS)
```

## Terraform Project Structure

Create this structure:

```
vod/
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── security-groups.tf
│   │   └── user-data.sh
│   └── README.md
├── server/
├── docker-compose.yml
└── ...
```

## Step 1: Create Terraform Variables

Create `infrastructure/terraform/variables.tf`:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "vod"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"  # 2 vCPU, 4GB RAM - good for Docker
}

variable "key_pair_name" {
  description = "Name of AWS key pair"
  type        = string
  default     = "vod-ec2-key"
}

variable "public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/vod-ec2-key.pub"
}

variable "allowed_ips" {
  description = "List of IPs allowed to SSH (your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Change this to your IP for security!
}

variable "db_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
  # You'll set this via terraform.tfvars or environment variable
}
```

## Step 2: Create Security Groups

Create `infrastructure/terraform/security-groups.tf`:

```hcl
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for VOD EC2 instance"

  # SSH access (only from allowed IPs)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
    description = "SSH"
  }

  # HTTP access (for Spring Boot API)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Spring Boot API"
  }

  # HTTPS (for future use)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}
```

## Step 3: Create Key Pair Resource

Add to `infrastructure/terraform/main.tf`:

```hcl
# Read public key
data "local_file" "public_key" {
  filename = pathexpand(var.public_key_path)
}

# Create AWS Key Pair
resource "aws_key_pair" "vod_key" {
  key_name   = var.key_pair_name
  public_key = data.local_file.public_key.content

  tags = {
    Name = "${var.project_name}-key-pair"
  }
}
```

## Step 4: Create EC2 Instance

Create `infrastructure/terraform/main.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 (optional, for future AWS service access)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instance
resource "aws_instance" "vod_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.vod_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # User data script runs on first boot
  user_data = file("${path.module}/user-data.sh")

  # Storage
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-server"
    Project = var.project_name
  }
}

# Elastic IP (optional - gives you a static IP)
resource "aws_eip" "vod_eip" {
  instance = aws_instance.vod_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}
```

## Step 5: Create User Data Script

Create `infrastructure/terraform/user-data.sh`:

```bash
#!/bin/bash
set -e

# Update system
sudo dnf update -y

# Install Docker
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo dnf install -y git

# Create app directory
sudo mkdir -p /opt/vod
sudo chown ec2-user:ec2-user /opt/vod

# Note: Application code will be deployed separately
# For now, just ensure Docker is ready
```

## Step 6: Create Outputs

Create `infrastructure/terraform/outputs.tf`:

```hcl
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vod_server.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_eip.vod_eip.public_ip
}

output "ec2_public_dns" {
  description = "EC2 public DNS name"
  value       = aws_instance.vod_server.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/vod-ec2-key ec2-user@${aws_eip.vod_eip.public_ip}"
}

output "api_url" {
  description = "API endpoint URL"
  value       = "http://${aws_eip.vod_eip.public_ip}:8080"
}
```

## Step 7: Create terraform.tfvars (Optional)

Create `infrastructure/terraform/terraform.tfvars.example`:

```hcl
aws_region    = "us-east-1"
project_name  = "vod"
instance_type = "t3.medium"
key_pair_name = "vod-ec2-key"
public_key_path = "~/.ssh/vod-ec2-key.pub"

# Get your IP: curl ifconfig.me
allowed_ips = ["YOUR_IP_HERE/32"]  # e.g., ["203.0.113.0/32"]

# Set via environment variable instead:
# export TF_VAR_db_password="your-secure-password"
```

## Step 8: Deploy Infrastructure

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Apply (creates resources)
terraform apply
# Type 'yes' when prompted

# View outputs
terraform output
```

## Step 9: Deploy Your Application

After EC2 is created, deploy your code:

```bash
# Get the public IP from Terraform output
EC2_IP=$(terraform output -raw ec2_public_ip)

# Copy your project to EC2
rsync -avz -e "ssh -i ~/.ssh/vod-ec2-key" \
  --exclude 'target/' \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  /home/khoa/programming/vod/ ec2-user@$EC2_IP:/opt/vod/

# SSH into the instance
ssh -i ~/.ssh/vod-ec2-key ec2-user@$EC2_IP

# On the EC2 instance:
cd /opt/vod
docker compose up -d
```

## Step 10: Create .gitignore for Terraform

Create `infrastructure/terraform/.gitignore`:

```
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl
terraform.tfvars
*.tfvars.backup
.terraform.tfstate.lock.info
```

## Important Security Notes

1. Restrict SSH access:

   ```hcl
   # In variables.tf, get your IP:
   # curl ifconfig.me
   allowed_ips = ["YOUR_IP/32"]
   ```

2. Use secrets management:

   ```bash
   # Don't put passwords in terraform.tfvars
   # Use environment variables:
   export TF_VAR_db_password="secure-password"
   ```

3. Use RDS for production (not Postgres on EC2):
   - More reliable
   - Automated backups
   - Better security
   - We can add this later

## Cost Estimation

- t3.medium: ~$0.0416/hour (~$30/month)
- EIP: Free if attached to running instance
- Data transfer: First 1GB free, then ~$0.09/GB
- Storage: 20GB gp3 ~$1.60/month

Total: ~$30-40/month for development/testing

## Next Steps

1. Deploy infrastructure with Terraform
2. Deploy application code
3. Test the API: `curl http://YOUR_EC2_IP:8080/api/health`
4. (Optional) Set up RDS instead of Postgres on EC2
5. (Optional) Add CloudFront for CDN
6. (Optional) Set up CI/CD for automated deployments

## Useful Commands

```bash
# View Terraform state
terraform show

# Destroy everything (careful!)
terraform destroy

# Update specific resource
terraform apply -target=aws_instance.vod_server

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate
```

This gives you a working EC2 deployment with Terraform. Start with `terraform init` and `terraform plan` to review what will be created.
