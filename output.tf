# define terraform module output values here 

output "docdb_cluster_endpoint" {
  description             = "DocumentDB Cluster Endpoint"
  value                   = aws_docdb_cluster.docdb_cluster.endpoint
}

output "docdb_cluster_members" {
  description             = "DocumentDB Cluster Endpoint"
  value                   = aws_docdb_cluster.docdb_cluster.cluster_members
}

output "docdb_vpc_endpoint_service_dns" {
  description             = "DocumentDB VPC Endpoint Service DNS"
  value                   = aws_vpc_endpoint_service.nlb_vpces.base_endpoint_dns_names
}

output "app_ec2_public_dns" {
  value                   = aws_instance.client_app.public_dns
}
 
output "app_docdb_vpc_endpoint_dns" {
  value                   = aws_vpc_endpoint.docdb_endpoint.dns_entry[0]
}

output "lambda_function_url" {
  value                   = aws_lambda_function_url.mylambda_func_url.function_url
}

output "app_ec2_ssh_command" {
  value                   = "ssh -i ${var.app_ssh_keypair_name}.pem ${aws_instance.client_app.public_dns}"
}

output "app_ec2_mongo_command" {
  value                   = "mongo --ssl --sslAllowInvalidHostnames --sslCAFile rds-combined-ca-bundle.pem --host ${aws_vpc_endpoint.docdb_endpoint.dns_entry[0].dns_name}:${var.docdb_port} --username ${var.docdb_master_user} --password <replace_this>"
}