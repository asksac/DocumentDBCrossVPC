data "dns_a_record_set" "docdb_dns_record" {
  host                    = aws_docdb_cluster.docdb_cluster.endpoint
}

resource "aws_lb_target_group_attachment" "nlb_tg_targets" {
  target_group_arn        = aws_lb_target_group.nlb_tg.arn
  target_id               = data.dns_a_record_set.docdb_dns_record.addrs[0]
}

# create parameter store entry
resource "aws_ssm_parameter" "docdb_ip_param" {
  name                  = local.docdb_ip_param_name
  type                  = "String"
  description           = "Last saved IP address of DocumentDB Cluster endpoint URL"
  value                 = data.dns_a_record_set.docdb_dns_record.addrs[0]

  # standard tier supports upto 4kb and advanced tier supports upto 8kb
  tier                  = "Standard" 
  overwrite             = false

  tags                  = local.common_tags
}
