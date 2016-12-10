/*resource "aws_instance" "mongodb" {
  count                  = 3
  instance_type          = "${var.mongodb_instance_type}"
  ami                    = "${var.aws_ami}"
  key_name               = "${var.ssh_key}"
  subnet_id              = "${element(module.vpc.private_subnets, count.index)}"
  vpc_security_group_ids = ["${module.vpc.default_security_group_id}", "${aws_security_group.mongodb.id}"]

  tags {
    Name    = "mongodb-${count.index}"
    role    = "mongodb"
    env     = "${var.environment}"
    project = "${var.project}"
  }

  root_block_device {
    delete_on_termination = true
  }
}

resource "aws_security_group" "mongodb" {
  name        = "mongodb-${var.project}-${var.environment}"
  description = "mongodb-${var.project}-${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name    = "mongodb-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    self      = true
  }
}

resource "aws_ebs_volume" "mongodb" {
  availability_zone = "${element(var.vpc_az, count.index)}"
  size              = "${var.mongodb_data_size}"
  count             = 3

  tags {
    Name    = "mongodb-${count.index}"
    role    = "mongodb"
    env     = "${var.environment}"
    project = "${var.project}"
    backup  = "true"
  }
}

resource "aws_volume_attachment" "mongodb" {
  count       = 3
  device_name = "/dev/sdd"
  volume_id   = "${element(aws_ebs_volume.mongodb.*.id, count.index)}"
  instance_id = "${element(aws_instance.mongodb.*.id, count.index)}"
}

resource "aws_route53_record" "mongodb" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  count   = 3
  name    = "mongodb-${count.index}.${var.domain_int}"
  type    = "A"
  ttl     = "60"
  records = ["${element(aws_instance.mongodb.*.private_ip, count.index)}"]
}*/

