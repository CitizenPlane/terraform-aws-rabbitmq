# Policies
resource "aws_iam_role" "ProxyRole" {
  name               = "${var.name}-${var.environment}-ProxyRole"
  assume_role_policy = "${file("${path.module}/policies/ProxyRole.json")}"
}

resource "aws_iam_instance_profile" "ProxyInstanceProfile" {
  name = "${var.name}-${var.environment}-ProxyInstanceProfile"
  role = "${aws_iam_role.ProxyRole.name}"
}

resource "aws_iam_role_policy" "ProxyPolicies" {
  name   = "${var.name}-${var.environment}-ProxyPolicies"
  policy = "${file("${path.module}/policies/ProxyPolicies.json")}"
  role   = "${aws_iam_role.ProxyRole.name}"
}
