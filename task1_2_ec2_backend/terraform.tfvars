aws_region = "ap-south-1"

instances = {
  "web-frontend" = {
    instance_type           = "t3.medium"
    root_volume_type        = "gp3"
    root_volume_size        = 30
    key_pair_name           = "frontend-deployer-key"
    environment             = "prod"
    owner                   = "ui-platform-team"
    prevent_destroy_enabled = false
  },
  "api-service" = {
    instance_type           = "c6i.xlarge"
    root_volume_type        = "gp3"
    root_volume_size        = 50
    key_pair_name           = "api-backend-key"
    environment             = "prod"
    owner                   = "backend-core-team"
    prevent_destroy_enabled = false
  },
  "analytics-worker" = {
    instance_type           = "m6i.large"
    root_volume_type        = "gp2"
    root_volume_size        = 100
    key_pair_name           = "data-pipeline-key"
    environment             = "analytics"
    owner                   = "data-platform-team"
    prevent_destroy_enabled = false
  },
  "database-primary" = {
    instance_type           = "r6i.2xlarge"
    root_volume_type        = "io2"
    root_volume_size        = 300
    root_iops               = 15000
    key_pair_name           = "db-cluster-key"
    environment             = "prod"
    owner                   = "database-reliability-team"
    prevent_destroy_enabled = true
  },
  "cache-cluster" = {
    instance_type           = "r6i.large"
    root_volume_type        = "standard"
    root_volume_size        = 40
    key_pair_name           = "cache-infra-key"
    environment             = "prod"
    owner                   = "caching-infra-team"
    prevent_destroy_enabled = false
  }
}
