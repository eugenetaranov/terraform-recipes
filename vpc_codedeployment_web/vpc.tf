module "vpc" {
  source                = "github.com/eugenetaranov/terraform-modules//tf-aws-vpc"
  name                  = "${var.project}-${var.environment}"
  cidr                  = "${var.vpc_cidr}"
  private_subnets       = "${var.vpc_private_subnets}"
  public_subnets        = "${var.vpc_public_subnets}"
  azs                   = "${var.vpc_az}"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  ssh_key               = "${var.ssh_key}"
  bastion_ami           = "${var.bastion_ami}"
  bastion_count         = "${var.bastion_count}"
  bastion_instance_type = "${var.bastion_instance_type}"
}

resource "aws_security_group_rule" "ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${module.vpc.default_security_group_id}"
  source_security_group_id = "${module.vpc.bastion_security_group_id}"
}

resource "aws_subnet" "redis" {
  vpc_id            = "${module.vpc.vpc_id}"
  cidr_block        = "${var.vpc_redis_subnets[count.index]}"
  availability_zone = "${var.vpc_az[count.index]}"
  count             = "${length(var.vpc_redis_subnets)}"

  tags {
    Name    = "${var.project}-${var.environment}-redis"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  map_public_ip_on_launch = "false"
}

output "bastion_instance" {
  value = "${module.vpc.bastion_ip}"
}
