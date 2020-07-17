data "template_file" "start_worker" {
  template = file("${path.module}/start_worker.sh")

  vars = {
    cluster_endpoint = aws_eks_cluster.cluster.endpoint
    cluster_ca       = aws_eks_cluster.cluster.certificate_authority.0.data
    cluster_name     = var.cluster_name
  }
}

data "aws_ami" "worker_node_ami" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

resource "aws_lb_target_group" "cluster_tg" {
  name        = "${aws_eks_cluster.cluster.name}-tg"
  port        = 31742
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_launch_configuration" "worker_launch_config" {
  name_prefix                 = "${aws_eks_cluster.cluster.name}-node"
  associate_public_ip_address = true
  aws_iam_instance_profile    = aws_iam_instance_profile.worker_node_instance_profile.name
  image_id                    = data.aws_ami.worker_node_ami.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  security_groups             = [aws_security_group.worker_node_security_group.id]
  user_data_base64            = base64encode(data.template_file.start_worker.rendered)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_nodes_asg" {
  name                 = "${aws_eks_cluster.cluster.name}-app-asg"
  desired_capacity     = var.app_size
  max_size             = var.app_size
  min_size             = var.app_size
  launch_configuration = aws_launch_configuration.worker_launch_config.id
  vpc_zone_identifier  = [var.app_subnet_ids]
  target_group_arns    = [aws_lb_target_group.cluster_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-db-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "db_nodes_asg" {
  name                 = "${aws_eks_cluster.cluster.name}-db-asg"
  desired_capacity     = var.db_size
  max_size             = var.db_size
  min_size             = var.db_size
  launch_configuration = aws_launch_configuration.worker_launch_config.id
  vpc_zone_identifier  = [var.db_subnet_ids]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-db-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
