/*
  ----------------------------------------------------------------------------------------------------------------------
                                                      VPC Flow Logs
  ----------------------------------------------------------------------------------------------------------------------
*/
resource "aws_flow_log" "vpc_network_flow_logs" {
  vpc_id          = aws_vpc.vpc_network.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.vpc_network_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_network_flow_logs.arn
}

resource "aws_cloudwatch_log_group" "vpc_network_flow_logs" {
  name = "vpc_network_flow_${var.envBuild}_logs"
}

resource "aws_iam_role" "vpc_network_flow_logs_role" {
  name = "vpc_network_flow_logs_${var.envBuild}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_network_flow_logs_policy" {
  name = "vpc_network_flow_logs_${var.envBuild}_policy"
  role = aws_iam_role.vpc_network_flow_logs_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
