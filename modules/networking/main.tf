resource "aws_vpc" "demo-vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.env}-vpc"
    }
}

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
