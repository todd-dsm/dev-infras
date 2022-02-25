/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                Amazon EKS Node Group
  ---------------------------------------------------------|------------------------------------------------------------
*/
resource "aws_eks_node_group" "apps" {
  cluster_name    = aws_eks_cluster.apps.name
  node_group_name = aws_eks_cluster.apps.name
  instance_types  = [var.kubeNode_type]
  node_role_arn   = aws_iam_role.apps_node_group.arn
  subnet_ids      = aws_subnet.vpc_network[*].id

  scaling_config {
    desired_size = var.minDistSize
    min_size     = var.minDistSize
    max_size     = var.maxDistSize
  }

  launch_template {
    id      = data.aws_launch_template.launch_template_apps.id
    version = data.aws_launch_template.launch_template_apps.latest_version
  }

  # Ignore desired_size in the case of scaling changes - and redness
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.apps_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.apps_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.apps_nodes_AmazonEC2ContainerRegistryReadOnly,
    data.aws_launch_template.launch_template_apps,
  ]

  tags = {
    #Name                                                 = var.cluster_apps
    #env                                                  = var.envBuild
    #project                                              = var.project
    "kubernetes.io/cluster/${aws_eks_cluster.apps.name}" = var.project
    DATADOG_FILTER                                       = random_uuid.datadog_uuid.id
  }
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                 Create Launch Template
  ---------------------------------------------------------|------------------------------------------------------------
*/
data "aws_launch_template" "launch_template_apps" {
  id         = aws_launch_template.launch_template_apps.id
  depends_on = [aws_launch_template.launch_template_apps]
}

resource "aws_launch_template" "launch_template_apps" {
  name = "launch-template-node-group-${var.envBuild}"
  tag_specifications {
    resource_type = "instance"
    tags = {
      DATADOG_FILTER = random_uuid.datadog_uuid.id
    }
  }
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Create IAM Roles
  ---------------------------------------------------------|------------------------------------------------------------
*/
resource "aws_iam_role" "apps_node_group" {
  name = "apps-node-group-${var.envBuild}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    DATADOG_FILTER = random_uuid.datadog_uuid.id
  }
}


resource "aws_iam_role_policy_attachment" "apps_nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.apps_node_group.name
}

resource "aws_iam_role_policy_attachment" "apps_nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.apps_node_group.name
}

resource "aws_iam_role_policy_attachment" "apps_nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.apps_node_group.name
}

# Attach AWS Load Balancer Controller policy to the managed node group
resource "aws_iam_role_policy_attachment" "lb_controller_nodes_apps" {
  policy_arn = aws_iam_policy.lb_controller_nodes.arn
  role       = aws_iam_role.apps_node_group.name
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                       KMS Policy
                                 Authorizes the nodes to reach out for the Vault KMS key.                               
  ---------------------------------------------------------|------------------------------------------------------------
*/
#data "aws_iam_policy_document" "kms_use_policy_document" {
#  depends_on = [aws_kms_key.vault-auto-unseal]
#  statement {
#    effect = "Allow"
#    actions = [
#      "kms:Encrypt",
#      "kms:Decrypt",
#      "kms:ReEncrypt*",
#      "kms:GenerateDataKey*",
#      "kms:DescribeKey",
#    ]
#    resources = [
#      aws_kms_key.vault-auto-unseal.arn
#    ]
#  }
#}
#
#resource "aws_iam_policy" "kms_use_policy_for_vault" {
#  name        = "KMS-Vault-Policy"
#  description = "Policy to allow use of KMS Key"
#  policy      = data.aws_iam_policy_document.kms_use_policy_document.json
#}
#
## For Vault Auto Unseal with KMS
#resource "aws_iam_role_policy_attachment" "kms_use_policy_attachment_for_vault" {
#  policy_arn = aws_iam_policy.kms_use_policy_for_vault.arn
#  role       = aws_iam_role.apps_node_group.name
#}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                EKS Worker Security Groups
  ---------------------------------------------------------|------------------------------------------------------------
*/
# This security group controls networking access to the Kubernetes worker nodes.
resource "aws_security_group" "apps_nodes" {
  name        = "apps-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.vpc_network.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_apps}" = "owned"
    DATADOG_FILTER                              = random_uuid.datadog_uuid.id
  }
}

resource "aws_security_group_rule" "apps_nodes_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.apps_nodes.id
  source_security_group_id = aws_security_group.apps_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "apps_nodes_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.apps_nodes.id
  source_security_group_id = aws_security_group.apps_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}


/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                  IAM Role for ExternalDNS
  ---------------------------------------------------------|------------------------------------------------------------
*/
data "aws_route53_zone" "apps_nodes_xdns_zone" {
  name         = var.dns_zone
  private_zone = true
}

resource "aws_iam_role_policy_attachment" "apps_nodes_worker_node_xdns_policy" {
  policy_arn = aws_iam_policy.apps_nodes_external_dns_policy.arn
  role       = aws_iam_role.apps_node_group.name
}

resource "aws_iam_policy" "apps_nodes_external_dns_policy" {
  name        = "xdns-apps-nodes-${var.envBuild}"
  path        = "/"
  description = "Allows EKS nodes to modify Route53 to support ExternalDNS."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                 IAM Role for CNI/IPv6
                REF: https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/iam-policy.md#ipv6-mode
  ---------------------------------------------------------|------------------------------------------------------------
*/
resource "aws_iam_role_policy_attachment" "apps-nodes-worker_node_cni_ipv6_policy" {
  policy_arn = aws_iam_policy.apps_nodes_cni_ipv6.arn
  role       = aws_iam_role.apps_node_group.name
}

resource "aws_iam_policy" "apps_nodes_cni_ipv6" {
  name        = "cni-ipv6-${var.cluster_apps}-nodes-${var.envBuild}"
  path        = "/"
  description = "Allows CNI pod to assign IPv6 addresses to pods that are not using the host network."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:AssignIpv6Addresses",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:network-interface/*",
            "Effect": "Allow"
        }
   ]
}
EOF
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                        OUTPUTS
  ---------------------------------------------------------|------------------------------------------------------------
*/
# Which zone did we find
#output "hosted_zone" {
#  value = data.aws_route53_zone.apps_nodes_xdns_zone.id
#}
