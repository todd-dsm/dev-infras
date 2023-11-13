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
    #aws_iam_role_policy_attachment.cluster_elb_sl_role_creation,
  ]
  tags = {
    "eks:cluster-name" = var.cluster_apps
  }
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                      EKS Logging
  AWS: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
  HTF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-control-plane-logging
  ---------------------------------------------------------|------------------------------------------------------------
*/
resource "aws_cloudwatch_log_group" "apps" {
  name              = "/aws/eks/${var.cluster_apps}/cluster"
  retention_in_days = 7
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Amazon EKS Addons
  ---------------------------------------------------------|------------------------------------------------------------
*/

#resource "aws_eks_addon" "example" {
#  cluster_name                = aws_eks_cluster.apps.name
#  addon_name                  = "coredns"
#  addon_version               = "v1.10.1-eksbuild.1" #e.g., previous version v1.9.3-eksbuild.3 and the new version is v1.10.1-eksbuild.1
#  resolve_conflicts_on_update = "PRESERVE"
#}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Amazon EKS IAM
  ---------------------------------------------------------|------------------------------------------------------------
*/
# Create IAM Role for the EKS Cluster
# REF: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
data "aws_iam_policy_document" "apps_cluster_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
        "ec2.amazonaws.com" # do I still need this?
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apps_cluster" {
  name               = var.cluster_apps
  assume_role_policy = data.aws_iam_policy_document.apps_cluster_policy.json
  tags = {
    Name = var.cluster_apps
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
  ---------------------------------------------------------|------------------------------------------------------------
                                             AWS Load Balancer Controller

  SIG: https://kubernetes-sigs.github.io/aws-load-balancer-controller
  Prerequisites:
    * amazon-vpc-cni-k8s https://github.com/aws/amazon-vpc-cni-k8s#readme
  ---------------------------------------------------------|------------------------------------------------------------
*/
#data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
#  statement {
#    effect = "Allow"
#    actions = [
#      "ec2:DescribeAccountAttributes",
#      "ec2:DescribeAddresses",
#      "ec2:DescribeInternetGateways"
#    ]
#    resources = ["*"]
#  }
#}
#
#resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
#  name_prefix = "${var.cluster_apps}-elb-sl-role-creation"
#  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
#  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation.json
#}
#
#resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
#  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation.arn
#  role       = aws_iam_role.apps_cluster.name
#}

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


