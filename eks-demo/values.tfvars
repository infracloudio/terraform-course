db-instance-type = ""
vpc_name = "Terraform-EKS"
vpc_cidr = "10.0.0.0/16"

vpc_private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
vpc_public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
app-instance-type = ""

app-scaling-desired-capacity = 2 

app-scaling-min-size = 1
app-scaling-max-size = 2

db-scaling-desired-capacity = 1
db-scaling-min-size = 1
db-scaling-max-size = 2

key_name = ""

bucket-name = ""


