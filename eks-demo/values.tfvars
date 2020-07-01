db-instance-type = ""
vpc_name = "Terraform-EKS"
vpc_cidr = "10.0.0.0/16"

#vpc_azs = data.aws_availability_zones.available.names #["us-east-1a","us-east-1b","us-east-1c"] slice(data.aws_availability_zones.available.names, 0, 2)
vpc_private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
vpc_public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
app-instance-type = "t3.small"

app-scaling-desired-capacity = 2 

app-scaling-min-size = 1
app-scaling-max-size = 2

#db-scaling-desired-capacity = 0
#db-scaling-min-size = 0
#db-scaling-max-size = 0
