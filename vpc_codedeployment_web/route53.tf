resource "aws_route53_zone" "internal" {
  name   = "${var.domain_int}"
  vpc_id = "${module.vpc.vpc_id}"

  tags {
    env     = "${var.environment}"
    project = "${var.project}"
  }
}
