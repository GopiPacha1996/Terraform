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

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.networking.vpcId
  env = var.env
  key = var.key
  public = var.public
  instance_type = var.instance_type
  avail_zone1 = var.avail_zone1
  subnet_id = module.networking.subnetId
  priavte_key_path = var.priavte_key_path
}
*/

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
}