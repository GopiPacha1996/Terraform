provider "aws" {
    region = "ap-south-1"
}
variable vpc_cidr {}
variable env {}
variable sgName{}
variable subnet_cidr1 {}
variable avail_zone1 {}
variable subnet_cidr2 {}
variable avail_zone2 {}
variable key {}
variable public {}

resource "aws_vpc" "demo-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env}-vpc"
    }
}
# singline line comment
/*
this is multi line 
comment used
*/

resource "aws_subnet" "demoSubnet1"{
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.subnet_cidr1
    availability_zone = var.avail_zone1
    tags = {
        Name = "${var.env}-subnet1"
    }
}

resource "aws_subnet" "demoSubnet2"{
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.subnet_cidr2
    availability_zone = var.avail_zone2
    tags = {
        Name = "${var.env}-subnet2"
}
}

resource "aws_internet_gateway" "demo-ig"{
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
        Name = "${var.env}-igw"
    }
}
/*
resource "aws_route_table" "demo-rt"{
    vpc_id = aws_vpc.demo-vpc.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-ig.id
  }
  tags = {
      Name = "${var.env}-rt"
  }
}
*/

resource "aws_default_route_table" "demo-rt"{
    default_route_table_id = aws_vpc.demo-vpc.default_route_table_id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-ig.id
  }
  tags = {
      Name = "${var.env}-rt"
  }
}

resource "aws_route_table_association" "rt-sub-1" {
    subnet_id = aws_subnet.demoSubnet1.id
    route_table_id = aws_default_route_table.demo-rt.id
}
resource "aws_route_table_association" "rt-sub-2" {
    subnet_id = aws_subnet.demoSubnet2.id
    route_table_id = aws_default_route_table.demo-rt.id
}

data "aws_ami" "myAmi" {
    owners = ["amazon"]
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
}

output "ami-id" {
    value = data.aws_ami.myAmi.id
}
/*
resource "aws_security_group" "demo-sg" {
    name = var.sgName
    vpc_id = aws_vpc.demo-vpc.id
    description = "this is created via TF"
    ingress {
    description      = "for HTTP requests"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "for ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
      Name = "${var.env}-sg"
  }
}
*/
resource "aws_default_security_group" "demo-sg"{
    vpc_id = aws_vpc.demo-vpc.id
    ingress {
    description      = "for HTTP requests"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "for ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
    description      = "for ssh"
    from_port        = 8989
    to_port          = 8989
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
      Name = "${var.env}-sg"
  }
}

resource "aws_key_pair" "myKey"{
    key_name = var.key
    public_key = file(var.public)
}

variable instance_type{}
variable priavte_key_path {}
resource "aws_instance" "demoinstance"{
    ami = data.aws_ami.myAmi.id
    instance_type= var.instance_type
    availability_zone = var.avail_zone1
    key_name = aws_key_pair.myKey.key_name
    vpc_security_group_ids = [aws_default_security_group.demo-sg.id]
    subnet_id = aws_subnet.demoSubnet1.id
    associate_public_ip_address = true
    tags = {
        Name = "${var.env}-ec2"
    }
  #  user_data = 
  connection {
      type = "ssh"
      host =  self.public_ip
      user = "ec2-user"
      private_key = file (var.priavte_key_path)
  }
    provisioner "file" {
        source = "./docker.sh"
        destination = "/home/ec2-user/ec2-docker.sh"
}
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/ec2-docker.sh",
      "/home/ec2-user/ec2-docker.sh",
    ]
  }
  provisioner "local-exec" {
      command = "echo ${self.public_ip} > ip.txt"
  }
}

output "Ip" {
    value = aws_instance.demoinstance.public_ip
}
