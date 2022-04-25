# Create a VPC endpoint for ELB - required if MonitorIPChange lambda is attached to VPC

# create a security group for vpc endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  count                   = var.lambda_in_docdb_vpc ? 1 : 0

  name                    = "${var.app_shortcode}_vpc_endpoint_sg"
  vpc_id                  = data.aws_vpc.docdb.id

  ingress {
    cidr_blocks           = [ data.aws_vpc.docdb.cidr_block ]
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
  }

  tags                    = local.common_tags
}

resource "aws_vpc_endpoint" "elb_endpoint" {
  count                   = var.lambda_in_docdb_vpc ? 1 : 0

  service_name            = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_id                  = data.aws_vpc.docdb.id
  subnet_ids              = data.aws_subnet.docdb.*.id
  private_dns_enabled     = true

  auto_accept             = true
  vpc_endpoint_type       = "Interface"

  security_group_ids      = [ aws_security_group.vpc_endpoint_sg[count.index].id ]

  policy = jsonencode({
    Version = "2012-10-17", 
    Statement = [
      {
        Sid = "AllowELBDescribeAndRegisterDeregisterTargetsAccess", 
        Principal = {
          AWS = local.account_id
        },
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:Describe*", 
          "elasticloadbalancing:RegisterTargets", 
          "elasticloadbalancing:DeregisterTargets"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags                    = merge(local.common_tags, tomap({"Name": "${var.app_shortcode}_elb_endpoint"}))
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  count                   = var.lambda_in_docdb_vpc ? 1 : 0

  service_name            = "com.amazonaws.${var.aws_region}.ssm"
  vpc_id                  = data.aws_vpc.docdb.id
  subnet_ids              = data.aws_subnet.docdb.*.id
  private_dns_enabled     = true

  auto_accept             = true
  vpc_endpoint_type       = "Interface"

  security_group_ids      = [ aws_security_group.vpc_endpoint_sg[count.index].id ]

  policy = jsonencode({
    Version = "2012-10-17", 
    Statement = [
      {
        Sid = "AllowSSMParameterStoreGetPutAccess", 
        Principal = {
          AWS = local.account_id
        },
        Effect = "Allow",
        Action      = [
          "ssm:GetParameter",
          "ssm:PutParameter",
        ], 
        Resource    = "arn:aws:ssm:*:*:parameter/*"
      }
    ]
  })

  tags                    = merge(local.common_tags, tomap({"Name": "${var.app_shortcode}_ssm_endpoint"}))
}