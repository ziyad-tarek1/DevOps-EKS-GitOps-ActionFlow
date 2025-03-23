
resource "aws_iam_role" "aws_lbc" {
  name               = "${var.cluster_name}-alb"
  assume_role_policy = file("${var.assume_role_policy_file_path}")

}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("${var.policy_file_path}")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_policy" "aws_elb" {
  name        = "AWSElasticLoadBalancerControllerPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeListenerCertificates",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:RegisterTargets",
        "ec2:DescribeSubnets",  
        "ec2:DescribeSecurityGroups",  
        "elasticloadbalancing:DeregisterTargets",
        "*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_elb" {
  policy_arn = aws_iam_policy.aws_elb.arn
  role       = aws_iam_role.aws_lbc.name
}



resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.aws_lbc.arn
}


resource "helm_release" "aws_lbc" {
  name = var.namespace

  repository = var.repository
  chart      = var.chart
  namespace  = var.namespace
  version    = var.chart_version

  # Add timeout
  timeout = 300 # 5 minutes

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }


  set {
    name  = "awsRegion"
    value = var.region # MUST be updated to match your region 
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  depends_on = [var.eks_dependency, aws_eks_pod_identity_association.aws_lbc]


}