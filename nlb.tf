# Create an NLB in front of documentdb cluster

resource "aws_lb" "nlb" {
  name                    = "${var.app_shortcode}-docdb-nlb"
  internal                = true
  load_balancer_type      = "network"

  subnets                 = data.aws_subnet.docdb.*.id
  enable_cross_zone_load_balancing  = false
  
  tags                    = local.common_tags
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn       = aws_lb.nlb.arn
  port                    = var.docdb_port # inbound port of NLB
  protocol                = "TCP"

  default_action {
    type                  = "forward"
    target_group_arn      = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  name                    = "${var.app_shortcode}-docdb-nlb-tg"
  port                    = var.docdb_port # outbound port of NLB / inbound of targets
  protocol                = "TCP"
  target_type             = "ip" # Auto Scaling requires target type to be instance
  vpc_id                  = data.aws_vpc.docdb.id
}

resource "aws_vpc_endpoint_service" "nlb_vpces" {
  acceptance_required        = false
  network_load_balancer_arns = [ aws_lb.nlb.arn ]

  tags                    = local.common_tags
}
