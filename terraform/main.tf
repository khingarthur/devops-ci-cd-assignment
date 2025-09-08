# Define the required Terraform version and providers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

# Define the provider and the AWS region.
provider "aws" {
  region = "us-east-2"
}

# Declare variables to be used in the configuration.
variable "key_name" {
  description = "The name of the EC2 key pair."
  type        = string
}

variable "docker_hub_username" {
  description = "The Docker Hub username."
  type        = string
}

variable "docker_image_tag" {
  description = "The tag of the Docker image to deploy."
  type        = string
}

# Create a new VPC for our environment.
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "app-vpc"
  }
}

# Create an internet gateway to allow communication with the internet.
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-igw"
  }
}

# Create a public subnet.
resource "aws_subnet" "app_subnet" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "app-public-subnet"
  }
}

# Create a route table and a route to the internet gateway.
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-route-table"
  }
}

resource "aws_route" "app_internet_route" {
  route_table_id         = aws_route_table.app_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app_igw.id
}

# Associate the route table with the public subnet.
resource "aws_route_table_association" "app_route_table_assoc" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route_table.id
}

# Create a security group to allow inbound traffic on ports 22 (SSH) and 5000 (Flask app).
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.app_vpc.id

  # Ingress rule for SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for the Flask app.
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

# Create the EC2 instance.
resource "aws_instance" "app_server" {
  ami           = "ami-0cfde0ea8edd312d4"
  instance_type = "t2.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id     = aws_subnet.app_subnet.id
  associate_public_ip_address = true

  # User data script to install Docker and run the application.
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Pull and run the Docker image from Docker Hub.
              sudo docker run -d -p 5000:5000 --name hello-app ${var.docker_hub_username}/hello-world-app:${var.docker_image_tag}
              EOF

  tags = {
    Name = "hello-world-server"
  }
}

# Output the public IP address of the EC2 instance.
output "app_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.app_server.public_ip
}
