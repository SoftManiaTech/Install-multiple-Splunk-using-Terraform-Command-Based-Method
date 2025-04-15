terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# ✅ Get Latest RHEL 9.x AMI
data "aws_ami" "latest_rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat AWS account

  filter {
    name   = "name"
    values = ["RHEL-9.?*-x86_64-*"]
  }
}

# ✅ Security Group
resource "aws_security_group" "splunk_sg" {
  name        = "splunk-security-group"
  description = "Allow Splunk ports"

  ingress { 
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 8000
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ Multiple EC2 Instances
resource "aws_instance" "splunk_server" {
  count         = var.instance_count
  ami           = data.aws_ami.latest_rhel.id
  instance_type = "t2.medium"
  key_name      = var.key_name
  security_groups = [aws_security_group.splunk_sg.name]

  user_data = file("splunk-setup.sh")

  tags = {
    Name = "Splunk-Server-${count.index + 1}"
  }
}
