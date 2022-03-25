
terraform {
  required_version = "~> 1.1.5"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.aws_account_id, terraform.workspace)}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}

terraform {
  required_version = ">=1.1.5"

  backend "s3" {
    bucket = "hqr.common.database.module.kojitechs.tf"
    key    = "path/env"
    region = "us-east-1"
  }
}

locals {
  default_tags    = module.required_tags.aws_default_tags
  master_password = var.create_db_instance && var.create_random_password ? random_string.master_user_password.result : var.password
  #   db_subnet_group_name   = !var.cross_region_replica && var.replicate_source_db != null ? null : coalesce(var.db_subnet_group_name, aws_db_subnet_group.flour_rds_subnetgroup[0].id, var.identifie)
  create_db_option_group = var.create_db_option_group && var.engine != "postgres"
  db_tenable_user        = "postgres_aa2"
  secrets                = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)
  engines_map = {
    aurora-postgresql = "postgres"
    postgres          = "postgres"
    redshift          = "redshift"
  }
  common_secret_values = {
    engine     = var.db_clusters.engine
    port       = var.db_clusters.port
    dbname     = var.db_clusters.dbname
    identifier = var.db_clusters.identifier
    password   = random_string.master_user_password.result
  }
  common_tenable_values = {
    engine   = local.engines_map[var.db_clusters.engine]
    endpoint = aws_db_instance.postgres_rds[0].address
    port     = var.db_clusters.port
    dbname   = var.db_clusters.dbname
    password = random_string.master_user_password.result
  }
}

module "required_tags" {
  source = "git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.tech_poc_secondary
  application             = "Database"
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.cell_name
  cell_name               = var.cell_name
  component_name          = var.component_name
}

resource "random_uuid" "shapshot_postfix" {

}

resource "random_string" "master_user_password" {

  length  = 16
  special = false
}

resource "random_password" "users_password" {
  for_each         = toset(var.db_users)
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "master_secret" {

  name_prefix             = format("%s_%s", var.component_name, "master_secret")
  description             = "secret to manage superuser ${var.db_clusters.name} on ${var.db_clusters.identifier} instance"
  recovery_window_in_days = 0

}

resource "aws_secretsmanager_secret" "users_secret" {

  for_each                = toset(var.db_users)
  name_prefix             = each.key == var.db_users ? "tenable-${var.component_name}" : var.component_name
  description             = "secret to manage user credential of ${each.key} on ${var.db_clusters.identifier} instance"
  recovery_window_in_days = 0

}
resource "aws_secretsmanager_secret_version" "master_secret_value" {

  secret_id     = aws_secretsmanager_secret.master_secret.id
  secret_string = jsonencode(merge(local.common_secret_values, { username = var.db_clusters.dbname, password = random_string.master_user_password.result }))
}

# Secrets Manager for all application users that requires a password 
resource "aws_secretsmanager_secret_version" "user_secret_value" {

  for_each      = toset(keys(aws_secretsmanager_secret.users_secret))
  secret_id     = aws_secretsmanager_secret.users_secret[each.key].id
  secret_string = jsonencode(merge(local.common_tenable_values, { username = each.key, password = random_password.users_password[each.key].result }))
}

resource "aws_db_instance" "postgres_rds" {
  count = var.create_db_instance ? 1 : 0

  allocated_storage = var.db_storage
  engine            = var.db_clusters.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class

  port                   = local.secrets["port"]
  username               = local.secrets["dbname"]
  password               = local.secrets["password"]
  vpc_security_group_ids = [module.Security_module.this[0]]

  identifier          = var.component_name
  skip_final_snapshot = var.skip_db_snapshot
  publicly_accessible = true
  #db_subnet_group_name = aws_db_subnet_group.flour_rds_subnetgroup[0].id
  multi_az = var.multi_az

  tags = {}
  lifecycle {
    ignore_changes = [
      identifier,
      engine_version,
      engine,
      password
    ]
  }
}

locals {
  ingress = {
    mysql = {
      from        = local.secrets["port"]
      to          = local.secrets["port"]
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "Security_module" {
  source = "git::git@github.com:Bkoji1150/hqr-security-group.git//Sg"

  vpc_id         = var.vpc_id
  ingress        = local.ingress
  description    = "Allow inbound traffic"
  Sg_description = "Allow inbound traffic to db"
  Tags           = format("%s_%s", var.component_name, "db_sg")
}

# resource "aws_db_subnet_group" "db_subnets" {
#   count       = var.create_db_instance ? 1 : 0
#   name_prefix = format("%s_%s", var.component_name, "db_subnets")
#   subnet_ids = var.db_subnets
# }

provider "postgresql" {

  alias            = "pgconnect"
  host             = aws_db_instance.postgres_rds[0].address
  port             = aws_db_instance.postgres_rds[0].port
  username         = var.db_clusters.dbname
  password         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser        = false
  sslmode          = "require"
  expected_version = aws_db_instance.postgres_rds[0].engine_version
  connect_timeout  = 15
}

resource "postgresql_database" "postgres" {

  for_each          = toset(var.databases_created)
  provider          = postgresql.pgconnect
  name              = each.key
  allow_connections = true
  depends_on        = [aws_db_instance.postgres_rds]
}

# (contains(var.databases_created, each.value.database)? each.value.database : "postgres"
resource "postgresql_schema" "my_schema" {
  for_each = {
    for schema, value in var.schemas_list_owners : schema => value
  }
  # Beware schema is a database object and not cluster object like users
  # Meaning the database you selected would dertermind were the schema would be created
  provider = postgresql.pgconnect
  name     = each.value.onwer == "database" || each.value.database == "schema" ? null : each.value.name_of_theschema
  owner    = each.value.onwer
  database = contains(var.databases_created, each.value.database) ? each.value.database : "postgres"
  policy {
    usage = each.value.usage
    role  = each.value.role
  }

  policy {
    create = each.value.with_create_object
    usage  = each.value.with_usage
    role   = each.value.role_name
  }
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_role" "users" {
  provider   = postgresql.pgconnect
  for_each   = toset(var.db_users)
  name       = each.key
  login      = true
  password   = random_password.users_password[each.key].result
  depends_on = [aws_db_instance.postgres_rds]
}

resource "postgresql_grant" "user_privileges" {
  for_each = {
    for idx, user_privileges in var.db_users_privileges : idx => user_privileges
    if contains(var.db_users, user_privileges.user)
  }

  database    = each.value.database
  provider    = postgresql.pgconnect
  role        = each.value.user
  privileges  = each.value.privileges
  object_type = each.value.type
  schema      = each.value.type == "database" && each.value.schema == "" ? null : each.value.schema
  objects     = each.value.type == "database" || each.value.type == "schema" ? null : each.value.objects
  depends_on  = [postgresql_role.users]
}
