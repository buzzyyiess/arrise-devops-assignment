resource "aws_s3_bucket" "target_bucket" {
  provider      = aws.account_b
  bucket        = "arrise-shared-artifacts-111111111111"
  force_destroy = false
}

resource "aws_iam_role" "role_c" {
  provider = aws.account_b
  name     = "roleC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOnlyRoleBFromAccountA"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::000000000000:role/roleB"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "role_c_s3_access" {
  provider = aws.account_b
  name     = "SingleBucketAccess"
  role     = aws_iam_role.role_c.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "BucketLevelOperations"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.target_bucket.arn
      },
      {
        Sid      = "ObjectLevelOperations"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.target_bucket.arn}/*"
      }
    ]
  })
}
