resource "aws_lambda_function" "ebs_snapshot" {
  filename         = "files/ebs_snapshot.zip"
  function_name    = "ebs_snapshot"
  role             = "${aws_iam_role.lambda-snapshot.arn}"
  handler          = "ebs_snapshot.lambda_handler"
  source_code_hash = "${base64sha256(file("files/ebs_snapshot.zip"))}"
  runtime          = "python2.7"
  timeout          = 30
}

resource "aws_iam_role" "lambda-snapshot" {
  name               = "${var.project}-${var.environment}-lambda-snapshot"
  assume_role_policy = "${file("policies/ebs_snapshot_role.json")}"
}

resource "aws_iam_role_policy" "ebs-snapshot-creator" {
  name   = "${var.project}-${var.environment}-lambda-snapshot"
  role   = "${aws_iam_role.lambda-snapshot.id}"
  policy = "${file("policies/ebs_snapshot_policy.json")}"
}

resource "aws_cloudwatch_event_rule" "lambda-snapshot" {
  name                = "lambda-snapshot"
  description         = "lambda-snapshot every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda-snapshot" {
  rule = "${aws_cloudwatch_event_rule.lambda-snapshot.name}"
  arn  = "${aws_lambda_function.ebs_snapshot.arn}"
}

resource "aws_lambda_permission" "lambda-snapshot" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ebs_snapshot.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda-snapshot.arn}"
}
