# define terraform module output values here 

output "docdb_cluster_endpoint" {
  description             = "DocumentDB Cluster Endpoint"
  value                   = aws_docdb_cluster.docdb_cluster.endpoint
}

output "docdb_cluster_members" {
  description             = "DocumentDB Cluster Endpoint"
  value                   = aws_docdb_cluster.docdb_cluster.cluster_members
}

output "docdb_vpc_endpoint_dns" {
  description             = "DocumentDB VPC Endpoint Service DNS"
  value                   = aws_vpc_endpoint_service.nlb_vpces.base_endpoint_dns_names
}

output "docdb_ip_addrs" {
  value                   = data.dns_a_record_set.docdb_dns_record.addrs
}

output "client_app_dns" {
  value                   = aws_instance.client_app.public_dns
}
 
output "docdb_app_endpoint_dns" {
  value                   = aws_vpc_endpoint.docdb_endpoint.dns_entry
}

