data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority[0].data}' '${var.cluster-name}'
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl --kubeconfig=/var/lib/kubelet/kubeconfig label nodes $(hostname) app=sample
USERDATA

}

resource "aws_launch_configuration" "app_launch_config" {
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.demo-node.name
  image_id = data.aws_ami.eks-worker.id
  instance_type = var.app-instance-type
  key_name = "kunal_eks"
  name_prefix = "eks-launch-config"
  security_groups = [aws_security_group.demo-node.id]
  user_data_base64 = base64encode(local.demo-node-userdata)
	
 # provisioner "local-exec"{
 # command=<<EOT
#      terraform output kubeconfig > config;
 #     terraform output config-map-aws-auth > config-map-aws-auth.yaml
	
#	EOT
#}
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
	terraform output kubeconfig > config;
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
  name_prefix = "eks-launch-config"
  security_groups = [aws_security_group.demo-node.id]
  user_data_base64 = base64encode(local.demo-node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "db_asg" {
  desired_capacity = var.db-scaling-desired-capacity
  launch_configuration = aws_launch_configuration.db_launch_config.id
  max_size = var.db-scaling-max-size
  min_size = var.db-scaling-min-size
  name = "eks-autoscaling-group"
  vpc_zone_identifier = module.vpc.private_subnets

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
