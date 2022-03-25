resource "aws_db_instance" "pg" {
  allocated_storage    = var.storage
  engine               = var.engine_type
  engine_version       = var.engine_type_version
  instance_class       = var.db_instance_type
  db_name              = var.dbName
  username             = var.user
  password             = var.password
  publicly_accessible  = true
  multi_az             = false
  skip_final_snapshot  = true

}