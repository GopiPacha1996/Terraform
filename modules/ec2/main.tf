data "aws_ami" "myAmi" {
    owners = ["amazon"]
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
}


resource "aws_default_security_group" "demo-sg"{
    vpc_id = var.vpc_id
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

resource "aws_instance" "demoinstance"{
    ami = data.aws_ami.myAmi.id
    instance_type= var.instance_type
    availability_zone = var.avail_zone1
    key_name = aws_key_pair.myKey.key_name
    vpc_security_group_ids = [aws_default_security_group.demo-sg.id]
    subnet_id = var.subnet_id
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
        source = "/home/ubuntu/terraform-aws/docker.sh"
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