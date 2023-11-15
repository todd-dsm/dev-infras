/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                   Amazon EKS OIDC
  ---------------------------------------------------------|------------------------------------------------------------
*/
resource "aws_iam_openid_connect_provider" "oidc_provider_apps" {
  client_id_list  = ["sts.${var.dns_suffix}"]
  thumbprint_list = [data.tls_certificate.oidc_data.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.apps.identity.0.oidc.0.issuer
  tags = {
    name = "${var.cluster_apps}-oidc"
  }
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                       Discovery
  ---------------------------------------------------------|------------------------------------------------------------
*/
# The cluster config won't emit a sha1_fingerprint so we must wait for it to become available,
# then use the data resource to get it.
data "tls_certificate" "oidc_data" {
  url = aws_eks_cluster.apps.identity.0.oidc.0.issuer

  depends_on = [
    aws_eks_cluster.apps
  ]
}

/*
  ---------------------------------------------------------|------------------------------------------------------------
                                                        OUTPUTS
  ---------------------------------------------------------|------------------------------------------------------------
*/
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc_provider_apps.arn
}