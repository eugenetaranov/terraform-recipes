resource "aws_launch_configuration" "web" {
  name_prefix                 = "web-${var.project}-${var.environment}-"
  image_id                    = "${var.web_ami}"
  instance_type               = "${var.web_instance_type}"
  key_name                    = "${var.ssh_key}"
  security_groups             = ["${module.vpc.default_security_group_id}", "${aws_security_group.web.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.web.id}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "web" {
  name  = "web-${var.project}-${var.environment}"
  roles = ["${aws_iam_role.web_ec2.name}"]
}

resource "aws_iam_role" "web_ec2" {
  name               = "web-ec2-${var.project}-${var.environment}"
  assume_role_policy = "${file("policies/iam_role_ec2.json")}"
}

resource "aws_iam_role_policy" "web_ec2" {
  name   = "web-ec2-${var.project}-${var.environment}"
  role   = "${aws_iam_role.web_ec2.id}"
  policy = "${data.template_file.web_ec2_policy.rendered}"
}

data "template_file" "web_ec2_policy" {
  template = "${file("templates/web_ec2_iam_policy.json")}"

  vars {
    bucket_name = "${aws_s3_bucket.web_codedeploy.id}"
  }
}

resource "aws_security_group" "web" {
  name        = "web-${var.project}-${var.environment}"
  description = "web-${var.project}-${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    Name    = "web-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }
}

resource "aws_autoscaling_group" "web" {
  availability_zones        = ["${var.vpc_az}"]
  name                      = "web-${var.project}-${var.environment}"
  max_size                  = "${var.web_asg_max_size}"
  min_size                  = "${var.web_asg_min_size}"
  desired_capacity          = "${var.web_asg_desired_capacity}"
  health_check_grace_period = "${var.web_asg_grace_period}"
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.web.name}"
  load_balancers            = ["${aws_elb.elb.name}"]
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"]

  tag {
    key                 = "project"
    value               = "${var.project}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "environment"
    value               = "${var.environment}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "role"
    value               = "web"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "asg"
    value               = "web-${var.project}-${var.environment}"
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_policy" "scaleout" {
  name                   = "web-${var.project}-${var.environment} scaleout"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_autoscaling_policy" "scalein" {
  name                   = "web-${var.project}-${var.environment} scalein"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
}

resource "aws_cloudwatch_metric_alarm" "web_scaleout" {
  alarm_name          = "web-${var.project}-${var.environment} scaleout alarm - CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This metric monitor ec2 cpu utilization, scaleout"
  alarm_actions       = ["${aws_autoscaling_policy.scaleout.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "web_scalein" {
  alarm_name          = "web-${var.project}-${var.environment} scalein alarm - CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "This metric monitor ec2 cpu utilization, scalein"
  alarm_actions       = ["${aws_autoscaling_policy.scalein.arn}"]
}

resource "aws_codedeploy_app" "web" {
  name = "web-${var.project}-${var.environment}"
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name              = "${aws_codedeploy_app.web.name}"
  deployment_group_name = "web-${var.project}-${var.environment}"

  /*service_role_arn   = "arn:aws:iam::427985443494:role/codedeploy"*/
  service_role_arn   = "${aws_iam_role.web_codedeploy.arn}"
  autoscaling_groups = ["${aws_autoscaling_group.web.name}"]
}

resource "aws_iam_role" "web_codedeploy" {
  name               = "web-codedeploy-${var.project}-${var.environment}"
  assume_role_policy = "${file("policies/iam_role_codedeploy.json")}"
}

resource "aws_iam_role_policy" "web_codedeploy" {
  name   = "web-codedeploy-${var.project}-${var.environment}"
  role   = "${aws_iam_role.web_codedeploy.id}"
  policy = "${file("policies/web_codedeploy_iam_policy.json")}"
}

resource "aws_s3_bucket" "web_codedeploy" {
  bucket        = "web-codedeploy-${var.project}-${var.environment}"
  acl           = "private"
  force_destroy = true

  tags {
    Name    = "web-codedeploy-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }
}
