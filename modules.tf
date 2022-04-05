/*
module "networking" {
   source = "./modules/networking/"
   vpc_cidr = var.root_vpc_cidr
   env = var.env
   subnet_cidr1 = var.subnet_cidr1
   subnet_cidr2 = var.subnet_cidr2
   avail_zone1  = var.avail_zone1
   avail_zone2  = var.avail_zone2
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "demo-vpc"
  cidr = var.root_vpc_cidr

  azs             = [var.avail_zone1,var.avail_zone2]
  public_subnets  = [var.subnet_cidr1,var.subnet_cidr2]
  public_subnet_tags = {Name = "demo-subenets"}

  tags = {
    Name = "existimg_vpc"
    Environment = "dev"
  }
}
module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  env = var.env
  key = var.key
  public = var.public
  instance_type = var.instance_type
  avail_zone1 = var.avail_zone1
  subnet_id = module.vpc.public_subnets[0]
  priavte_key_path = var.priavte_key_path
}

module "s3" {
  source = "/home/ubuntu/common-modules/s3"
  bucketName = var.bucketName
}

module "rds" {
  source = "/home/ubuntu/common-modules/rds"
  storage = var.storage
  engine_type = var.engine_type
  engine_type_version = var.engine_type_version
  db_instance_type = var.db_instance_type
  dbName = var.dbName
  user = var.user
  password = var.password
}*/

terraform {
  backend "s3" {
    bucket = "tf-backend-statefile"
    key    = "qa.tfstate"
    region = "ap-south-1"

  }
}

variable subnets_cidr {
  description = "list of subnet cidrs"
  type = list(string)
  default = ["10.0.0.0/24","10.0.1.0/24"]
}
variable azs {
  type = list
  default = ["us-east-1a","us-east-1b","us-east-1c"]
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = var.root_vpc_cidr
    tags = {
        Name = "${var.env}-vpc"
    }
}
resource "aws_subnet" "subnet"{
    vpc_id = aws_vpc.demo-vpc.id
    count = length(var.subnets_cidr)
    cidr_block = element (var.subnets_cidr,count.index)
    availability_zone = element(var.azs,count.index)
    tags = {
        Name = "${var.env}-subnet-${count.index+1}"
    }
}
resource "aws_default_route_table" "demo-rt"{
    default_route_table_id = aws_vpc.demo-vpc.default_route_table_id
  tags = {
      Name = "${var.env}-rt"
  }
}

resource "aws_route_table_association" "rt-sub-1" {
    count = length(var.subnets_cidr)
    subnet_id = element(aws_subnet.subnet.*.id,count.index)
    route_table_id = aws_default_route_table.demo-rt.id
}
