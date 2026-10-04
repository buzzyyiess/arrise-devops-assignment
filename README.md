# Arrise Solutions - DevOps Infrastructure Engineer III Assessment
Environment ready Terraform modules, IAM security policies, and architectural analysis.

## Repository Layout
- `task1_2_ec2_backend/`: Dynamic multi-instance EC2 provisioning, IOPS configuration, S3 remote state backend, and DynamoDB lock[cite: 1].
- `task3_iam_cross_account/`: Multi-account IAM isolation, user groups, and cross-account delegation[cite: 1].
- `task4_least_privilege/`: Scoped CI/CD IAM policy for ECR, ECS, and S3[cite: 1].
- `task5_bug_fix/`: Corrected Terraform configuration for cross-account STS delegation[cite: 1].
- `NOTES.md`: Architectural decisions, failure root causes, security trade-offs, and assignment answers[cite: 1].

## Architectural Notes & Rationale
Please review **[NOTES.md](./NOTES.md)** for detailed technical analysis, lifecycle protection rationale, bug root-cause breakdown, and least-privilege scoping decisions[cite: 1].

## Local Validation (Zero-Dependency)

All Terraform modules and IAM policies can be validated locally using standard tooling without incurring AWS costs or requiring active cloud credentials:

```bash
# 1. Export mock credentials for provider resolution
export AWS_ACCESS_KEY_ID="mock_key"
export AWS_SECRET_ACCESS_KEY="mock_secret"
export AWS_DEFAULT_REGION="ap-south-1"

# 2. Validate Task 1 & 2 (EC2 & Backend configuration)
cd task1_2_ec2_backend
terraform init -backend=false
terraform validate

# 3. Validate Task 3 (Multi-Account IAM)
cd ../task3_iam_cross_account
terraform init
terraform validate

# 4. Validate Task 4 (Least-Privilege CI JSON Policy)
cd ../task4_least_privilege
python3 -m json.tool ci_iam_policy.json > /dev/null && echo "CI Policy JSON is Valid"

# 5. Validate Task 5 (Bug Fix Verification)
cd ../task5_bug_fix
terraform init
terraform validate
