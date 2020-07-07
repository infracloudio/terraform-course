variable "cluster-name" {
  default = "terraform-eks"
  type    = string
}

variable "vpc_cidr"{

type = string
}

variable "vpc_name"{
type = string
}

#variable "vpc_azs"{

#}

variable "vpc_private_subnets"{
type = list
}

variable "vpc_public_subnets"{
type = list
}
variable "db-instance-type"{
type = string
}

variable "app-instance-type"{

type = string

}
variable "app-scaling-desired-capacity"{

type = number

}

variable "app-scaling-min-size"{
type = number
}

variable "app-scaling-max-size"{
type = number
}

variable "db-scaling-desired-capacity"{
type = number
}
variable "db-scaling-min-size"{
type = number
}

variable "db-scaling-max-size"{
type = number
}


variable "bucket-name"{
type = string
}
