resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1-programmatic-cli"
}

resource "aws_iam_user" "engine" {
  provider = aws.account_a
  name     = "engine"
}

resource "aws_iam_user" "ci" {
  provider = aws.account_a
  name     = "ci"
}

resource "aws_iam_group_membership" "group1_members" {
  provider = aws.account_a
  name     = "group1-membership"
  group    = aws_iam_group.group1.name
  users    = [aws_iam_user.engine.name, aws_iam_user.ci.name]
}

resource "aws_iam_group_policy" "deny_console_access" {
  provider = aws.account_a
  name     = "deny-console-access"
  group    = aws_iam_group.group1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAWSConsoleUI"
        Effect   = "Deny"
        Action   = ["aws-portal:*", "signin:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2-console-cli"
}

resource "aws_iam_user" "lead_eng" {
  provider = aws.account_a
  name     = "arun.kumar"
}

resource "aws_iam_user" "senior_sre" {
  provider = aws.account_a
  name     = "priya.sharma"
}

resource "aws_iam_group_membership" "group2_members" {
  provider = aws.account_a
  name     = "group2-membership"
  group    = aws_iam_group.group2.name
  users    = [aws_iam_user.lead_eng.name, aws_iam_user.senior_sre.name]
}

resource "aws_iam_role" "role_a" {
  provider = aws.account_a
  name     = "roleA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::000000000000:root" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "role_a_permissions" {
  provider = aws.account_a
  name     = "AdminExceptIAM"
  role     = aws_iam_role.role_a.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAllServices"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid      = "ExplicitDenyIAM"
        Effect   = "Deny"
        Action   = ["iam:*", "organizations:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_b" {
  provider = aws.account_a
  name     = "roleB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::000000000000:root" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "role_b_assume_role_c" {
  provider = aws.account_a
  name     = "AssumeRoleCInAccountBOnly"
  role     = aws_iam_role.role_b.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeRoleCOnly"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::111111111111:role/roleC"
      }
    ]
  })
}
