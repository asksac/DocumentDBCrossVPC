# creates an application instance (EC2)

data "aws_ami" "ec2_ami" {
  most_recent             = true
  owners                  = ["amazon"]

  filter {  
    name                  = "name"
    values                = ["amzn2-ami-hvm-2*"]
  } 

  filter {  
    name                  = "architecture"
    values                = ["x86_64"]
  } 

  filter {  
    name                  = "root-device-type"
    values                = ["ebs"]
  } 

  filter {  
    name                  = "virtualization-type"
    values                = ["hvm"]
  } 
}

resource "aws_instance" "client_app" {
  ami                     = data.aws_ami.ec2_ami.id

  subnet_id               = data.aws_subnet.app[0].id
  vpc_security_group_ids  = [ aws_security_group.app_sg.id ]

  instance_type           = "t3.small"
  credit_specification {
    cpu_credits           = "standard"
  }
  key_name                = var.app_ssh_keypair_name

  user_data               = <<EOF
#!/bin/bash -xe

echo -e "[mongodb-org-4.0] \nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.0/x86_64/\ngpgcheck=1 \nenabled=1 \ngpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" | tee /etc/yum.repos.d/mongodb-org-4.0.repo
yum install -y mongodb-org-shell

EOF

  tags                    = merge(local.common_tags, tomap({"Name": "${var.app_shortcode}-client-app"}))
}

resource "aws_vpc_endpoint" "docdb_endpoint" {
  vpc_id                  = data.aws_vpc.app.id
  service_name            = aws_vpc_endpoint_service.nlb_vpces.service_name
  vpc_endpoint_type       = "Interface"

  security_group_ids      = [ aws_security_group.vpce_sg.id ]

  subnet_ids              = data.aws_subnet.app.*.id
  private_dns_enabled     = false
}
