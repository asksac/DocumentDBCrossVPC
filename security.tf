# create security groups

resource "aws_security_group" "docdb_sg" {
  name                        = "${var.app_shortcode}_docdb_sg"
  vpc_id                      = data.aws_vpc.docdb.id

  ingress {
    cidr_blocks               = [ data.aws_vpc.docdb.cidr_block ]
    from_port                 = var.docdb_port
    to_port                   = var.docdb_port
    protocol                  = "tcp"
  }

  egress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = -1
    self                      = true
  }

  tags                        = local.common_tags
}

resource "aws_security_group" "app_sg" {
  name_prefix             = "${var.app_shortcode}_client_app_sg"
  vpc_id                  = data.aws_vpc.app.id

  ingress {
    cidr_blocks           = var.app_ssh_cidr_blocks
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
  }

  # terraform removes the default egress rule, so lets add it back
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group" "vpce_sg" {
  name_prefix             = "${var.app_shortcode}_vpce_sg"
  vpc_id                  = data.aws_vpc.app.id

  ingress {
    cidr_blocks           = [ data.aws_vpc.app.cidr_block ]
    from_port             = var.docdb_port
    to_port               = var.docdb_port
    protocol              = "tcp"
  }

}

