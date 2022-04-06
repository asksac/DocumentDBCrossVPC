variable "aws_profile" {
  type                    = string
  default                 = "default"
  description             = "Specify an aws profile name to be used for access credentials (run `aws configure help` for more information on creating a new profile)"
}

variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for resource creations"
}

variable "aws_env" {
  type                    = string
  default                 = "dev"
  description             = "Specify a value for the Environment tag"
}

variable "app_name" {
  type                    = string
  description             = "Specify an application or project name, used primarily for tagging"
}

variable "app_shortcode" {
  type                    = string
  description             = "Specify a short-code or pneumonic for this application or project"
}

variable "docdb_vpc_id" {
  type                    = string
  description             = "Specify a VPC ID where DocumentDB and NLB resources will be created"
}

variable "docdb_subnet_ids" {
  type                    = list 
  description             = "Specify a list of Subnet IDs where DocumentDB and NLB resources will be deployed"
}

variable "docdb_port" {
  type                    = number 
  default                 = 27017
  description             = "Specify port number to be used for DocumentDB and NLB listerner"
}

variable "docdb_master_user" {
  type                    = string 
  description             = "Specify a username to be used as master user for DocumentDB cluster"
}

variable "app_vpc_id" {
  type                    = string
  description             = "Specify a VPC ID where Client App resources will be created"
}

variable "app_subnet_ids" {
  type                    = list 
  description             = "Specify a list of Subnet IDs where Client App resources will be deployed"
}

variable "app_ssh_cidr_blocks" {
  type                    = list
  description             = "Specify list of source CIDR blocks to allow SSH access from"
}

variable "app_ssh_keypair_name" {
  type                    = string
  description             = "Specify name of an existing keypair to be used for SSH access to EC2 instances"
}

