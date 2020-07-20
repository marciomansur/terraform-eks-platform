resource "aws_security_group" "master_security_group" {
  name   = "${var.cluster_name}-master-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_security_group_rule" "worker_node_ingress_https_rule" {
  type                     = "ingress"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.master_security_group.id
  source_security_group_id = aws_security_group.worker_node_security_group.id
  to_port                  = 443
}

//resource "aws_security_group_rule" "workstation_https_access" {
//  count             = var.enable_ssh == true ? 1 : 0
//  type              = "ingress"
//  from_port         = 443
//  protocol          = "tcp"
//  security_group_id = aws_security_group.master_security_group.id
//  cidr_blocks       = [var.workstation_ip]
//  to_port           = 443
//}
//
//resource "aws_security_group_rule" "workstation_ssh_access" {
//  count             = var.enable_ssh == true ? 1 : 0
//  type              = "ingress"
//  from_port         = 22
//  protocol          = "tcp"
//  security_group_id = aws_security_group.master_security_group.id
//  cidr_blocks       = [var.workstation_ip]
//  to_port           = 22
//}
