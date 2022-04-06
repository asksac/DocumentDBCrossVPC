# create documentdb cluster

resource "random_password" "docdb_master_password" {
  length           = 16
  special          = false
}

resource "aws_docdb_subnet_group" "default" {
  name                    = "${var.app_shortcode}-docdb-subnets"
  subnet_ids              = data.aws_subnet.docdb.*.id

  tags                    = local.common_tags
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier      = "${var.app_shortcode}-docdb-cluster"
  engine                  = "docdb"

  db_subnet_group_name    = aws_docdb_subnet_group.default.name
  port                    = var.docdb_port
  vpc_security_group_ids  = [ aws_security_group.docdb_sg.id ]

  master_username         = var.docdb_master_user
  master_password         = random_password.docdb_master_password.result

  backup_retention_period = 2
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true

  storage_encrypted       = true
  tags                    = local.common_tags
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count                   = length(var.docdb_subnet_ids)
  identifier              = "${var.app_shortcode}-docdb-cluster-inst-${count.index}"
  cluster_identifier      = aws_docdb_cluster.docdb_cluster.id
  instance_class          = "db.t3.medium"
}
