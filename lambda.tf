#
# This script performs the following steps: 
# 1. Creates a CloudWatch Log group  for Lambda function to write logs to
# 2. Creates a ZIP pacakge from Lambda source file(s)
# 3. Creates an IAM execution role for Lambda
# 4. Creates a Lambda function resource using local ZIP file as source
#

resource "aws_security_group" "lambda_vpc_sg" {
  name                        = "${var.app_shortcode}_lambda_sg"
  vpc_id                      = data.aws_vpc.docdb.id

  ingress {
    cidr_blocks               = data.aws_vpc.docdb.cidr_block_associations.*.cidr_block
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }

  egress {
    cidr_blocks               = data.aws_vpc.docdb.cidr_block_associations.*.cidr_block
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }

  tags                        = local.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 7 
}

data "archive_file" "mylambda_archive" {
  source_file     = "${path.module}/lambda/MonitorIPChange/main.py"
  output_path     = "${path.module}/dist/MonitorIPChange.zip"
  type            = "zip"
}

resource "aws_lambda_function" "mylambda_func" {
  function_name     = var.lambda_name 

  handler           = "main.lambda_handler"
  role              = aws_iam_role.lambda_exec_role.arn
  runtime           = "python3.8"
  timeout           = 60

  filename          = data.archive_file.mylambda_archive.output_path
  source_code_hash  = data.archive_file.mylambda_archive.output_base64sha256

  # connect lambda to docdb vpc if enabled
  dynamic "vpc_config" {
    for_each        = var.lambda_in_docdb_vpc ? [1] : []

    content {
      subnet_ids      = data.aws_subnet.docdb.*.id
      security_group_ids  = [ aws_security_group.lambda_vpc_sg.id ] 
    }
  }

  environment {
    variables       = {
      ENDPOINT_URL = aws_docdb_cluster.docdb_cluster.endpoint
      NLB_TARGET_GROUP_ARN = aws_lb_target_group.nlb_tg.arn
      DOCDB_IP_PARAM_NAME = local.docdb_ip_param_name
    }
  }

  tags             = local.common_tags
}

resource "aws_lambda_alias" "mylambda_latest" {
  name             = "${var.lambda_name}-Latest"
  description      = "Alias for latest Lambda version"
  function_name    = aws_lambda_function.mylambda_func.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_function_url" "mylambda_func_url" {
  function_name       = aws_lambda_function.mylambda_func.function_name
  authorization_type  = "NONE"
}

# Create Lambda execution IAM role, giving permissions to access other AWS services

resource "aws_iam_role" "lambda_exec_role" {
  name                = "${var.app_shortcode}_Lambda_Exec_Role"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
          "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "LambdaAssumeRolePolicy"
      }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.app_shortcode}_Lambda_Policy"
  path        = "/"
  description = "IAM policy with minimum permissions for ${var.lambda_name} Lambda function"

  policy = jsonencode({
    Version         = "2012-10-17"
    Statement       = [
      {
        Action      = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces", 
          "ec2:DeleteNetworkInterface", 
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowCreateManageENIAccess"
      }, 
      {
        Action      = [
          "logs:CreateLogGroup",
        ]
        Resource    = "arn:aws:logs:*:*:log-group:/aws/lambda/${var.lambda_name}"
        Effect      = "Allow"
        Sid         = "AllowCloudWatchLogsAccess"
      }, 
      {
        Action      = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource    = "arn:aws:logs:*:*:log-group:/aws/lambda/${var.lambda_name}:*"
        Effect      = "Allow"
        Sid         = "AllowCloudWatchPutLogEvents"
      }, 
      {
        Action      = [
          "ssm:GetParameter",
          "ssm:PutParameter",
        ]
        Resource    = "arn:aws:ssm:*:*:parameter/*"
        Effect      = "Allow"
        Sid         = "AllowSSMParameterStoreGetPutAccess"
      }, 
      {
        Action      = [
          "elasticloadbalancing:DescribeTargetHealth", 
          "elasticloadbalancing:RegisterTargets", 
          "elasticloadbalancing:DeregisterTargets", 
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowELBDescribeAccess"
      }, 
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
