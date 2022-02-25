/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Amazon EKS Cluster
                                    Amazon Elastic Container Service for Kubernetes
                                  AWS manages the Controllers Customer manages workers
                    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
  ---------------------------------------------------------|------------------------------------------------------------
*/
# Build the EKS Controller
resource "aws_eks_cluster" "apps" {
  name     = var.cluster_apps
  role_arn = aws_iam_role.apps_cluster.arn

  #  kubernetes_network_config {
  #    ip_family = "ipv6"
  #  }

  vpc_config {
    security_group_ids = [aws_security_group.apps_cluster.id]
    subnet_ids         = aws_subnet.vpc_network[*].id
  }

  # Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_cloudwatch_log_group.apps,
    aws_iam_role_policy_attachment.apps_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.apps_cluster-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.apps_cluster-AmazonEKSVPCResourceControllerPolicy,
    aws_iam_role_policy_attachment.cluster_elb_sl_role_creation,
  ]

  tags = {
    "kubernetes.io/cluster/${var.cluster_apps}" = var.project
    DATADOG_FILTER                              = random_uuid.datadog_uuid.id
  }
}

# Setup controller logging
resource "aws_cloudwatch_log_group" "apps" {
  name              = "/aws/eks/${var.cluster_apps}/cluster"
  retention_in_days = 30

  tags = {
    "kubernetes.io/cluster/${var.cluster_apps}" = var.project
    DATADOG_FILTER                              = random_uuid.datadog_uuid.id
  }
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Amazon EKS IAM
  ---------------------------------------------------------|------------------------------------------------------------
*/
# Create IAM Role for the EKS Cluster
# REF: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "apps_cluster" {
  name = "${var.cluster_apps}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "ec2.amazonaws.com"
         ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {
    Name           = var.cluster_apps
    DATADOG_FILTER = random_uuid.datadog_uuid.id
  }
}

### Attach Policies to the above Role
# Cluster Policy
resource "aws_iam_role_policy_attachment" "apps_cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.apps_cluster.name
}

# Service Policy
resource "aws_iam_role_policy_attachment" "apps_cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.apps_cluster.name
}

# EKS-VPC Resource Controller
resource "aws_iam_role_policy_attachment" "apps_cluster-AmazonEKSVPCResourceControllerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.apps_cluster.name
}

/*
 Adding a policy for cluster IAM role to allow permissions required to create
 AWSServiceRoleForElasticLoadBalancing service-linked role by EKS during ELB provisioning
*/
data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
  name_prefix = "${var.cluster_apps}-elb-sl-role-creation"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation.json
}

resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation.arn
  role       = aws_iam_role.apps_cluster.name
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                    EKS Security Groups
  ---------------------------------------------------------|------------------------------------------------------------
*/
### EKS Cluster: allow all outbound traffic
resource "aws_security_group" "apps_cluster" {
  name        = "${var.cluster_apps}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc_network.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = var.cluster_apps
    "kubernetes.io/cluster/${var.cluster_apps}" = "shared"
    DATADOG_FILTER                              = random_uuid.datadog_uuid.id
  }
}

## Cluster access from workers
#resource "aws_security_group_rule" "apps_cluster-ingress-node-https" {
#  description              = "Allow pods to communicate with the cluster API Server"
#  from_port                = 0
#  protocol                 = "-1"
#  security_group_id        = aws_security_group.apps_cluster.id
#  source_security_group_id = aws_security_group.apps-node.id
#  to_port                  = 65535
#  type                     = "ingress"
#}
#
## Allow inbound traffic from the Office Gateway
#resource "aws_security_group_rule" "apps_cluster-ingress-workstation-https" {
#  cidr_blocks       = [var.officeIPAddr]
#  description       = "Allow workstation to communicate with the cluster API Server"
#  from_port         = 443
#  protocol          = "tcp"
#  security_group_id = aws_security_group.apps_cluster.id
#  to_port           = 443
#  type              = "ingress"
#}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                    EKS CloudWatch Metrics
  ---------------------------------------------------------|------------------------------------------------------------
*/
#resource "aws_iam_role_policy_attachment" "apps_cluster-cw-metrics" {
#  policy_arn = aws_iam_policy.apps_cluster-cw-metrics.arn
#  role       = aws_iam_role.apps_cluster.name
#}
#
#resource "aws_iam_policy" "apps_cluster-cw-metrics" {
#  name        = "cw-metrics-kube-test-nodes-${var.envBuild}"
#  path        = "/"
#  description = "Allows EKS to push metrics to CloudWatch."
#
#  policy = <<EOF
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Action": [
#                "cloudwatch:PutMetricData"
#            ],
#            "Resource": "*",
#            "Effect": "Allow"
#        }
#    ]
#}
#EOF
#}