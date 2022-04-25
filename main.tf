/**
 * # Terraform Module - DocumentDBCrossVPC
 *
 */

data "aws_caller_identity" "current" {}

data "aws_vpc" "docdb" {
  id                      = var.docdb_vpc_id
}

data "aws_subnet" "docdb" {
  count                   = length(var.docdb_subnet_ids)
  id                      = var.docdb_subnet_ids[count.index]
}

data "aws_vpc" "app" {
  id                      = var.app_vpc_id
}

data "aws_subnet" "app" {
  count                   = length(var.app_subnet_ids)
  id                      = var.app_subnet_ids[count.index]
}

locals {
  # Common tags to be assigned to all resources
  common_tags             = {
    Application           = var.app_name
    Environment           = var.aws_env
  }

  account_id              = data.aws_caller_identity.current.account_id
  docdb_ip_param_name     = "/${var.app_shortcode}/${var.aws_env}/lambda/${var.lambda_name}/docdb_saved_ip_address"
}

