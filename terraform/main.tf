#provider block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#aws_vpc
resource "aws_vpc" "enitos" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "enitos"
  }
}

#aws_subnet
resource "aws_subnet" "enitos_subnet" {
  vpc_id     = aws_vpc.enitos.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "enitos"
  }
}

#aws_internet_gateway
resource "aws_internet_gateway" "enitos" {
  vpc_id = aws_vpc.enitos.id

  tags = {
    Name = "enitos"
  }

}

#aws_route_table
resource "aws_route_table" "enitos_rt" {
  vpc_id = aws_vpc.enitos.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.enitos.id
  }

  tags = {
    Name = "enitos_subnet"
  }
}

#aws_route_table_association
resource "aws_main_route_table_association" "enitos_rta" {
  vpc_id         = aws_vpc.enitos.id
  route_table_id = aws_route_table.enitos_rt.id
}

#aws_security_group
resource "aws_security_group" "enitos_sg" {
  name        = "enitos_sg"
  description = "enitos_sg"
  vpc_id      = aws_vpc.enitos.id

  tags = {
    Name = "enitos_sg"
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#aws_key_pair
resource "aws_key_pair" "enny" {
  key_name   = "enny"
  public_key = file("/home/enitos/enny.pub")
}

#aws_ami
# #resource "aws_ami" "ubuntu { 
#     name = "terraform-ubuntu" 
#     virtualization_type = "hvm"
#     root_device_name = "dev/xvda"
#     imds_support = "1.0.1"
#     ebs_block_device {
#       device_name = "dev/xvda"
#       snapshot_id = "snap-xxxxx"
#     volume_size = 8
#     }


##aws-instance
resource "aws_instance" "enitos" {
  ami           = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  count         = 5
  key_name = aws_key_pair.enny.key_name
  vpc_security_group_ids = [ aws_security_group.enitos_sg.id ]
  subnet_id = aws_subnet.enitos_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "enitos"
  }
}

# #output "enitos_ip" {
#   value = aws_instance.enitos.public_ip
# }