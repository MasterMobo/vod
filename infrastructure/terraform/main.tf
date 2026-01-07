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
# resource "aws_iam_role" "ec2_role" {
#   name = "${var.project_name}-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = {
#     Name = "${var.project_name}-ec2-role"
#   }
# }

# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "${var.project_name}-ec2-profile"
#   role = aws_iam_role.ec2_role.name
# }

resource "aws_instance" "vod_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.vod_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  # iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # User data script runs on first boot
  user_data = file("${path.module}/user-data.sh")

  # Storage
  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name    = "${var.project_name}-server"
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
