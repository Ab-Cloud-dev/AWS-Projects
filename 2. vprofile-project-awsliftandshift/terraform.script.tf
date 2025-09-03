# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
  # Replace with your actual IP address
  default     = "0.0.0.0/0"
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# VPC
resource "aws_vpc" "vprofile_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "vprofile-vpc"
    Project = "vprofile"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "vprofile_igw" {
  vpc_id = aws_vpc.vprofile_vpc.id

  tags = {
    Name    = "vprofile-igw"
    Project = "vprofile"
  }
}

# Subnets
# Public Subnet for ALB
resource "aws_subnet" "vprofile_subnet_alb" {
  vpc_id                  = aws_vpc.vprofile_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "vprofile_Subnet-ALB"
    Description = "Public Subnet for ALB"
    Project     = "vprofile"
  }
}

# Private Subnet for App Layer
resource "aws_subnet" "vprofile_subnet_app" {
  vpc_id            = aws_vpc.vprofile_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "vprofile_Subent-app"
    Description = "Subnet for the App Layer"
    Project     = "vprofile"
  }
}

# Private Subnet for DB Layer
resource "aws_subnet" "vprofile_subnet_dbs" {
  vpc_id            = aws_vpc.vprofile_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name        = "vprofile_Subnet-Dbs"
    Description = "Subnet for the DB Layer"
    Project     = "vprofile"
  }
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "vprofile-nat-eip"
    Project = "vprofile"
  }
}

resource "aws_nat_gateway" "vprofile_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.vprofile_subnet_alb.id

  tags = {
    Name    = "vprofile-nat"
    Project = "vprofile"
  }

  depends_on = [aws_internet_gateway.vprofile_igw]
}

# Route Tables
# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vprofile_igw.id
  }

  tags = {
    Name    = "vprofile-public-rt"
    Project = "vprofile"
  }
}

# Route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vprofile_nat.id
  }

  tags = {
    Name    = "vprofile-private-rt"
    Project = "vprofile"
  }
}

# Route table associations
resource "aws_route_table_association" "public_subnet_alb" {
  subnet_id      = aws_subnet.vprofile_subnet_alb.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_app" {
  subnet_id      = aws_subnet.vprofile_subnet_app.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_dbs" {
  subnet_id      = aws_subnet.vprofile_subnet_dbs.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
# 1. ELB Security Group
resource "aws_security_group" "vprofile_elb_sg" {
  name        = "vprofile-ELB-SG"
  description = "Security Group for L.B"
  vpc_id      = aws_vpc.vprofile_vpc.id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "vprofile-ELB-SG"
    Project = "vprofile"
  }
}

# 2. App Security Group
resource "aws_security_group" "vprofile_app_sg" {
  name        = "vprofile-app-sg"
  description = "Security Group for tomcat app server"
  vpc_id      = aws_vpc.vprofile_vpc.id

  ingress {
    description     = "Port 8080 from ELB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_elb_sg.id]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "vprofile-app-sg"
    Project = "vprofile"
  }
}

# 3. Backend Security Group
resource "aws_security_group" "vprofile_backend_sg" {
  name        = "vprofile-backend-sg"
  description = "Allow Mysql, Memcache and RabbitMq from tomcatserver"
  vpc_id      = aws_vpc.vprofile_vpc.id

  ingress {
    description     = "MySQL from app server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id]
  }
  
    ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description     = "Memcache from app server"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id]
  }

  ingress {
    description     = "RabbitMQ from app server"
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile_app_sg.id]
  }

  ingress {
    description = "All traffic from itself"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "vprofile-backend-sg"
    Project = "vprofile"
  }
}

# Key Pair
resource "aws_key_pair" "vprofile_prod_key" {
  key_name   = "vprofile-prod-key"
  public_key = file("~/.ssh/vprofile-prod-key.pub") # You need to generate this key pair locally

  tags = {
    Name        = "vprofile-prod-key"
    Description = "For the Production Server"
    Project     = "vprofile"
  }
}

# EC2 Instances
# 1. Database Instance
resource "aws_instance" "vprofile_db01" {
  ami                    = "ami-08a6efd148b1f7504"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  subnet_id              = aws_subnet.vprofile_subnet_dbs.id

  tags = {
    Name    = "vprofile-db01"
    Project = "vprofile"
  }

  volume_tags = {
    Project = "vprofile"
  }
}

# 2. Memcache Instance
resource "aws_instance" "vprofile_mc01" {
  ami                    = "ami-08a6efd148b1f7504"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  subnet_id              = aws_subnet.vprofile_subnet_dbs.id

  tags = {
    Name    = "vprofile-mc01"
    Project = "vprofile"
  }

  volume_tags = {
    Project = "vprofile"
  }
}

# 3. RabbitMQ Instance
resource "aws_instance" "vprofile_rmq01" {
  ami                    = "ami-08a6efd148b1f7504"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids = [aws_security_group.vprofile_backend_sg.id]
  subnet_id              = aws_subnet.vprofile_subnet_dbs.id

  tags = {
    Name    = "vprofile-rmq01"
    Project = "vprofile"
  }

  volume_tags = {
    Project = "vprofile"
  }
}

# 4. App Instance
resource "aws_instance" "vprofile_app01" {
  ami                    = "ami-020cba7c55df1f615"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.vprofile_prod_key.key_name
  vpc_security_group_ids = [aws_security_group.vprofile_app_sg.id]
  subnet_id              = aws_subnet.vprofile_subnet_app.id

  tags = {
    Name    = "vprofile-app01"
    Project = "vprofile"
  }

  volume_tags = {
    Project = "vprofile"
  }
}

# Outputs
output "vpc_id" {
  value       = aws_vpc.vprofile_vpc.id
  description = "ID of the VPC"
}

output "db_instance_private_ip" {
  value       = aws_instance.vprofile_db01.private_ip
  description = "Private IP of database instance"
}

output "mc_instance_private_ip" {
  value       = aws_instance.vprofile_mc01.private_ip
  description = "Private IP of memcache instance"
}

output "rmq_instance_private_ip" {
  value       = aws_instance.vprofile_rmq01.private_ip
  description = "Private IP of RabbitMQ instance"
}

output "app_instance_private_ip" {
  value       = aws_instance.vprofile_app01.private_ip
  description = "Private IP of app instance"
}

output "alb_subnet_id" {
  value       = aws_subnet.vprofile_subnet_alb.id
  description = "ID of ALB subnet"
}

output "app_subnet_id" {
  value       = aws_subnet.vprofile_subnet_app.id
  description = "ID of app subnet"
}

output "db_subnet_id" {
  value       = aws_subnet.vprofile_subnet_dbs.id
  description = "ID of database subnet"
}