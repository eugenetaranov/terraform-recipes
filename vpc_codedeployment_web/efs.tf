/*resource "aws_efs_file_system" "default" {
  creation_token = "${var.project}-${var.environment}"

  tags {
    Name    = "${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = "${aws_efs_file_system.default.id}"
  subnet_id       = "${element(module.vpc.private_subnets, count.index)}"
  count           = "${length(var.vpc_private_subnets)}"
  ip_address      = "${cidrhost(var.vpc_private_subnets[count.index], 25)}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name        = "efs-${var.project}-${var.environment}"
  description = "efs-${var.project}-${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name    = "efs-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }
}

output "efs" {
  value = "${aws_efs_mount_target.default.dns_name}"
}*/

