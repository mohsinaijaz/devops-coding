provider "aws" {
  region     = "${var.aws_region}"
  }
resource "aws_vpc" "Dev" {
  cidr_block       = "190.160.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Dev_VPC"
  }
}
resource "aws_subnet" "Dev" {
  vpc_id     = "${aws_vpc.Dev.id}"
  cidr_block = "190.160.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Dev_Subnet"
  }
}
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = "${aws_vpc.Dev.id}"
  tags = {
    Name = "Dev_IGW"
  }
}
resource "aws_route_table" "dev_rtb" {
  vpc_id = "${aws_vpc.Dev.id}"
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.dev_igw.id}"
  }
tags = {
    Name = "Dev_rtb"
  }
}
resource "aws_route_table_association" "dev_rta" {
  subnet_id      = "${aws_subnet.Dev.id}"
  route_table_id = "${aws_route_table.dev_rtb.id}"
}
resource "aws_security_group" "dev_sg_22" {
  name = "dev_sg_22"
  vpc_id = "${aws_vpc.Dev.id}"
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Dev_SG"
  }
}
resource "aws_instance" "Dev_Postgresql" {
  ami           = "ami-0cfee17793b08a293"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.Dev.id}"
  vpc_security_group_ids = ["${aws_security_group.dev_sg_22.id}"]
  key_name = "${aws_key_pair.ec2_key.key_name}"
tags = {
  Name = "Dev_Postgresql"
}
  provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get upgrade -y",
    "sudo apt-get install python -y",
    "sudo apt-get install ansible -y",
  ]
}
provisioner "local-exec" {
      command = <<EOD
cat << EOF > hosts
[dev]
${aws_instance.Dev_Postgresql.public_ip}
[dev:vars]
EOF
EOD
  }
  provisioner "local-exec" {
       command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.Dev_Postgresql.id} && ansible-playbook -i dev dev_postgres_playbook.yml"
     }
connection {
  type     = "ssh"
  user     = "ubuntu"
  password = ""
  private_key = "${file("~/.ssh/id_rsa")}"
  host = "${aws_instance.Dev_Postgresql.public_ip}"
}
}
resource "aws_vpc" "Prod" {
  cidr_block       = "190.20.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Prod_VPC"
  }
}
resource "aws_subnet" "Prod" {
  vpc_id     = "${aws_vpc.Prod.id}"
  cidr_block = "190.20.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Prod_Subnet"
  }
}
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = "${aws_vpc.Prod.id}"
  tags = {
    Name = "Prod_IGW"
  }
}
resource "aws_route_table" "prod_rtb" {
  vpc_id = "${aws_vpc.Prod.id}"
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.prod_igw.id}"
  }
tags = {
    Name = "Prod_rtb"
  }
}
resource "aws_route_table_association" "prod_rta" {
  subnet_id      = "${aws_subnet.Prod.id}"
  route_table_id = "${aws_route_table.prod_rtb.id}"
}
resource "aws_security_group" "prod_sg_22" {
  name = "prod_sg_22"
  vpc_id = "${aws_vpc.Prod.id}"
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Prod_SG"
  }
}
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2_key"
  public_key = "${var.public_key}"
}
resource "aws_instance" "Prod_Postgresql" {
  ami           = "ami-0cfee17793b08a293"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.Prod.id}"
  vpc_security_group_ids = ["${aws_security_group.prod_sg_22.id}"]
  key_name = "${aws_key_pair.ec2_key.key_name}"
 tags = {
  Name = "Prod_Postgresql"
 }
 provisioner "remote-exec" {
   inline = [
     "sudo apt-get update",
     "sudo apt-get upgrade -y",
     "sudo apt-get install python -y",
     "sudo apt-get install ansible -y",
   ]
 }
 provisioner "local-exec" {
       command = <<EOD
cat << EOF >> hosts
[prod]
${aws_instance.Prod_Postgresql.public_ip}
[prod:vars]
EOF
EOD
   }
   provisioner "local-exec" {
        command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.Prod_Postgresql.id} && ansible-playbook -i prod prod_postgres_playbook.yml"
      }
 connection {
   type     = "ssh"
   user     = "ubuntu"
   password = ""
   private_key = "${file("~/.ssh/id_rsa")}"
   host = "${aws_instance.Prod_Postgresql.public_ip}"
 }
}
