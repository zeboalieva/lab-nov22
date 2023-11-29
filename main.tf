resource "aws_key_pair" "cloud_2021" {
  key_name   = "cloud_2021"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "cloud_2021_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "cloud_2021_vpc"
  }
}

resource "aws_subnet" "cloud_2021_subnet" {
  vpc_id                  = aws_vpc.cloud_2021_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "cloud_2021_subnet"
  }
}

resource "aws_internet_gateway" "cloud_2021_igw" {
  vpc_id = aws_vpc.cloud_2021_vpc.id

  tags = {
    Name = "cloud_2021_igw"
  }
}

resource "aws_route_table" "cloud_2021_rt" {
  vpc_id = aws_vpc.cloud_2021_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud_2021_igw.id
  }

  tags = {
    Name = "cloud_2021_rt"
  }
}

resource "aws_route_table_association" "cloud_2021_rta" {
  subnet_id      = aws_subnet.cloud_2021_subnet.id
  route_table_id = aws_route_table.cloud_2021_rt.id
}

module "security_groups" {
  source          = "app.terraform.io/tf-class-september-20/security-groups/aws"
  version         = "1.0.0"
  vpc_id          = aws_vpc.cloud_2021_vpc.id
  security_groups = var.security_groups
}

resource "aws_instance" "my_cloud_2021_instance" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.cloud_2021.key_name

  subnet_id              = aws_subnet.cloud_2021_subnet.id
  vpc_security_group_ids = [module.security_groups.security_group_id["cloud_2021"]]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd.service
              sudo systemctl enable httpd.service
              sudo echo "<h1> hard homework </h1>" > /var/www/html/index.html                   
              EOF 

  tags = {
    Name = "cloud_2021_instance"
  }
}

resource "aws_eip" "cloud_2021_eip" {
  instance = aws_instance.my_cloud_2021_instance.id
  domain   = "vpc"
}

output "my_eip" {
  value = aws_eip.cloud_2021_eip.public_ip
}

import {
  to = aws_instance.my_cloud_2021_instance
  id = "i-0ef5cf6486bbe1ed3"
}