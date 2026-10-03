# Engineering Notes & Architectural Rationale

## 1. Task 1: Protected Instance Selection & Lifecycle Rationale
* **Selected Instance:** `database-primary` (`r6i.2xlarge`, `io2` storage).
* **Rationale:** In stateful tier services (OLTP databases, game state persistence, core datastores), disk and compute identity termination can lead to immediate downtime, split-brain state, or catastrophic data loss.
* **Implementation Strategy:** Terraform does not allow variable interpolation inside static `lifecycle` blocks (`lifecycle { prevent_destroy = var.flag }` fails static compilation). To solve this cleanly without duplicating 5 individual resource definitions, instances are dynamically partitioned into two resource pools using `for_each` filters based on `prevent_destroy_enabled`.

## 2. Task 2: State Concurrency & Backend Mechanism
* **What happens with local state:** If Engineer 1 and Engineer 2 execute `terraform apply` concurrently, both instances read the identical `terraform.tfstate` from their local working directory. Both calculate divergent execution plans, start modifying cloud resources asynchronously, and overwrite each other's state outputs. This causes out-of-band resource drift, phantom resources, or irreversible state corruption.
* **Remote State with DynamoDB Locking:**
  1. **Acquire Lock:** Terraform makes an atomic `PutItem` call with a conditional check to the DynamoDB lock table before planning/applying.
  2. **Concurrency Halt:** When the second engineer runs `apply`, DynamoDB rejects the acquisition with a conditional check failure, prompting Terraform to halt with a `StateLockError`.
  3. **Release Lock:** Upon completion or failure, Terraform releases the lock item, guaranteeing sequential and atomic mutations.

## 3. Task 3: Production IAM Practices & Trust Scoping
* **Would we issue static IAM Users/Access Keys to `engine` and `ci`?**
  * **Short Answer:** Absolutely not.
  * **Production Approach:**
    * For CI/CD (GitHub Actions, GitLab CI, Jenkins on K8s), we implement **OpenID Connect (OIDC)** federated authentication with AWS STS (`sts:AssumeRoleWithWebIdentity`). This eliminates long-lived static credentials (`aws_access_key_id` and `aws_secret_access_key`). Ephemeral, short-lived tokens (max 1 hour) are issued dynamically.
    * For backend execution engines running on EC2/ECS/EKS, we leverage **IAM Instance Profiles / Pod Identities / IRSA (IAM Roles for Service Accounts)**.
* **Why specific role ARN vs. Account Root in Role C Trust Policy?**
  * **Root Trust (`arn:aws:iam::000000000000:root`):** Delegates authorization entirely to Account A administrators. Any identity in Account A that obtains `sts:AssumeRole` permissions from Account A IAM admins can assume `roleC`. Account B loses sovereign authorization control over who enters its perimeter.
  * **Specific ARN Trust (`arn:aws:iam::000000000000:role/roleB`):** Enforces a **bilateral contract (defense-in-depth)**. Even if an Account A administrator grants an engineer or another rogue role permission to assume `roleC`, AWS STS will reject the attempt at the boundary of Account B unless the caller's ARN is explicitly `roleB`.

## 4. Task 4: Scoping CI Permissions
* **Deliberately Excluded Permissions:**
  * `s3:PutObject`, `s3:DeleteObject`: The build artifact bucket is read-only for CI. Denying write prevents compromised dependencies or malicious CI actions from tampering with shared historical artifacts.
  * `ecr:DeleteRepository`, `ecr:DeleteRepositoryPolicy`, `ecr:SetRepositoryPolicy`: Administrative and destructive actions are reserved for Platform/Infra teams.
  * `ecs:CreateService`, `ecs:DeleteService`: CI only rolls out new tasks to existing services; it must never teardown services.
  * `iam:CreateRole`, `iam:AttachRolePolicy`: Scoped strictly down to `iam:PassRole` conditioned only on `ecs-tasks.amazonaws.com`. Without the condition, CI could pass administrative roles to arbitrary resources.

## 5. Task 5: Detailed Bug Breakdown
1. **Principal ARN Entity Mismatch:** The principal identifier had `:user/roleB`. AWS IAM strictly differentiates namespaces between `user` and `role`. Because `roleB` was created as an IAM Role, STS could not resolve `:user/roleB`, resulting in an authorization failure.
2. **Wildcard Scope Violation:** The permission policy granted `s3:*` on `*`. This violated the core requirement of granting access *only* to a single named bucket, exposing every current and future S3 bucket in Account B.
