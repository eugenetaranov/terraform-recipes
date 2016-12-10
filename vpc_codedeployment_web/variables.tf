variable "project" {
  default = "project"
}

variable "environment" {
  default = "production"
}

variable "domain_int" {
  default = "prod.project.int"
}

variable "vpc_cidr" {
  default = "10.12.0.0/16"
}

variable "vpc_public_subnets" {
  default = ["10.12.1.0/24", "10.12.3.0/24", "10.12.5.0/24"]
}

variable "vpc_private_subnets" {
  default = ["10.12.2.0/24", "10.12.4.0/24", "10.12.6.0/24"]
}

variable "vpc_redis_subnets" {
  default = ["10.12.7.0/24", "10.12.8.0/24", "10.12.9.0/24"]
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_az" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ecs_image" {
  default = "ami-3d55272a"
}

variable "ecs_instance_type" {
  default = "t2.micro"
}

variable "asg_max_size" {
  default = "2"
}

variable "asg_min_size" {
  default = "0"
}

variable "asg_desired_capacity" {
  default = "0"
}

variable "ssh_key" {
  default = "relevance-admin"
}

variable "bastion_instance_type" {
  default = "t2.nano"
}

variable "bastion_ami" {
  default = "ami-c481fad3"
}

variable "bastion_count" {
  default = 1
}

variable "mongodb_instance_type" {
  default = "t2.micro"
}

variable "aws_ami" {
  default = "ami-b73b63a0"
}

variable "mongodb_data_size" {
  default = 10
}

variable "web_ami" {
  default = "ami-08fef81f"
}

variable "web_instance_type" {
  default = "t2.nano"
}

variable "web_asg_min_size" {
  default = 1
}

variable "web_asg_max_size" {
  default = 2
}

variable "web_asg_desired_capacity" {
  default = 1
}

variable "web_asg_grace_period" {
  default = 10
}

variable "elb_principal" {
  type = "map"

  default = {
    us-east-1    = "127311923021"
    us-east-2    = "033677994240"
    us-west-1    = "027434742980"
    us-west-2    = "797873946194"
    eu-west-1    = "156460612806"
    eu-central-1 = "054676820928"
  }
}

variable "redis_instance_type" {
  default = "cache.t2.micro"
}
