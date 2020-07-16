resource "aws_iam_role" "worker_node_role" {
  name = "${var.cluster_name}-worker-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_instance_profile" "worker_node_instance_profile" {
  name = var.cluster_name
  role = aws_iam_role.worker_node_role.name
}

resource "aws_security_group" "worker_node_security_group" {
  name   = "${var.cluster_name}-worker-node-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = concat(var.app_subnet_ids, var.db_subnet_ids)
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_security_group_rule" "master_ingress_rule" {
  type                     = "ingress"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_node_security_group.id
  source_security_group_id = var.vpc_security_group_id
  to_port                  = 65535
}

resource "aws_security_group_rule" "master_ingress_https_rule" {
  type                     = "ingress"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_node_security_group.id
  source_security_group_id = var.vpc_security_group_id
  to_port                  = 443
}
