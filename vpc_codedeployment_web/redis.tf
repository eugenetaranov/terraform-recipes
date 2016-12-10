/*resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project}-${var.environment}"
  engine               = "redis"
  node_type            = "${var.redis_instance_type}"
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"

  tags {
    Name    = "${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "redis-${var.project}-${var.environment}"
  description = "redis${var.project}-${var.environment}"
  subnet_ids  = ["${aws_subnet.redis.*.id}"]
}

resource "aws_security_group" "redis" {
  name        = "redis-${var.project}-${var.environment}"
  description = "redis-${var.project}-${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"

  tags {
    env     = "redis-${var.project}-${var.environment}"
    env     = "${var.environment}"
    appname = "${var.project}"
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }
}

output "redis" {
  value = "${aws_elasticache_cluster.redis.cache_nodes.0.address}"
}*/

