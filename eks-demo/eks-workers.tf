data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  app-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority[0].data}' '${var.cluster-name}' --kubelet-extra-args '--node-labels=app=test'
USERDATA

}

locals {
  db-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority[0].data}' '${var.cluster-name}' --kubelet-extra-args '--node-labels=app=db'
USERDATA

}
resource "aws_launch_configuration" "app_launch_config" {
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.demo-node.name
  image_id = data.aws_ami.eks-worker.id
  instance_type = var.app-instance-type
  key_name = var.key_name
  name_prefix = "eks-launch-config"
  security_groups = [aws_security_group.demo-node.id]
  user_data_base64 = base64encode(local.app-node-userdata)


lifecycle {
    create_before_destroy = true


}
}


resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = var.app-scaling-desired-capacity
  launch_configuration = aws_launch_configuration.app_launch_config.id
  max_size = var.app-scaling-max-size
  min_size = var.app-scaling-min-size
  name = "eks-autoscaling-group"
  vpc_zone_identifier = module.vpc.private_subnets

  provisioner "local-exec"{

  command = <<EOT
  terraform output kubeconfig > ~/.kube/config
  terraform output config-map-aws-auth > config-map-aws-auth.yml
  kubectl apply -f config-map-aws-auth.yml
EOT
}

  tag {
    key = "Name"
    value = "terraform-eks-autoscaling-group"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.cluster-name}"
    value = "owned"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "db_launch_config" {
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.demo-node.name
  image_id = data.aws_ami.eks-worker.id
  instance_type = var.db-instance-type
  name_prefix = "eks-db-launch-config"
  security_groups = [aws_security_group.demo-node.id]
  key_name = var.key_name
  user_data_base64 = base64encode(local.db-node-userdata)




  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "db_asg" {
  desired_capacity = var.db-scaling-desired-capacity
  launch_configuration = aws_launch_configuration.db_launch_config.id
  max_size = var.db-scaling-max-size
  min_size = var.db-scaling-min-size
  name = "eks-db-autoscaling-group"
  vpc_zone_identifier = module.vpc.private_subnets

  provisioner "local-exec"{

  command = <<EOT
  terraform output kubeconfig > ~/.kube/config
  terraform output config-map-aws-auth > config-map-aws-auth.yml
  EOT
} 
  tag {
    key = "Name"
    value = "terraform-eks-autoscaling-group"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.cluster-name}"
    value = "owned"
    propagate_at_launch = true
  }
}
