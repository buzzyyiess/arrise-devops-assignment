# Arrise Solutions / Pragmatic Play - DevOps Infrastructure Engineer III Assessment

Production-ready Terraform modules, IAM security policies, and architectural analysis.

## Repository Layout
- `task1_2_ec2_backend/`: Dynamic multi-instance EC2 module, IOPS config, S3 remote state, and DynamoDB lock.
- `task3_iam_cross_account/`: Multi-account IAM isolation and least-privilege delegation.
- `task4_least_privilege/`: Scoped CI IAM policy for ECR/ECS/S3.
- `task5_bug_fix/`: Fixed Terraform configuration for cross-account STS delegation.
- `NOTES.md`: Architectural decisions, failure root causes, and tradeoffs.

## Local Validation with LocalStack
\`\`\`bash
# 1. Start LocalStack
localstack start -d

# 2. Bootstrap Local State S3 and DynamoDB
awslocal s3 mb s3://arrise-tfstate-prod-ap-south-1 --region ap-south-1
awslocal dynamodb create-table \
  --table-name arrise-tfstate-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

# 3. Test Task 1 & 2
cd task1_2_ec2_backend
tflocal init
tflocal validate
tflocal plan
\`\`\`
