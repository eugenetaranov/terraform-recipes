resource "aws_elb" "elb" {
  name = "web-${var.project}-${var.environment}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags {
    Name    = "web-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  subnets                   = ["${module.vpc.public_subnets}"]
  security_groups           = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing = true
  idle_timeout              = 600

  access_logs {
    bucket   = "${aws_s3_bucket.elb_logs.id}"
    interval = 5
  }
}

resource "aws_security_group" "elb" {
  name        = "elb-${var.project}-${var.environment}"
  description = "elb-${var.project}-${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name    = "elb-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "elb_logs" {
  bucket        = "web-logs-${var.project}-${var.environment}"
  acl           = "private"
  policy        = "${data.template_file.elb_logs_policy.rendered}"
  force_destroy = true

  tags {
    Name    = "web-logs-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  lifecycle {
    ignore_changes = ["policy"]
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "elb_logs_policy" {
  template = "${file("templates/elb_logs_s3_policy.json")}"

  vars {
    account_id    = "${data.aws_caller_identity.current.account_id}"
    bucket_name   = "web-logs-${var.project}-${var.environment}"
    elb_principal = "${var.elb_principal[var.region]}"
  }
}

output "loadbalancer" {
  value = "${aws_elb.elb.dns_name}"
}
