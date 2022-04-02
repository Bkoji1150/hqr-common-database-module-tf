
locals {
  master_password        = var.create_db_instance && var.create_random_password ? random_string.master_user_password.result : var.password
  create_db_option_group = var.create_db_option_group && var.db_engine != "postgres"
  create_database        = var.create_database && var.putin_khuylo
  rds_security_group_id  = join("", aws_security_group.this.*.id)
  secrets                = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)
  engines_map = {
    aurora-postgresql = "postgres"
    postgres          = "postgres"
    redshift          = "redshift"
  }
  common_secret_values = {
    dbname   = var.db_username
    endpoint = aws_db_instance.postgres_rds[0].address
    engine   = var.db_engine
    port     = var.db_port
    password = random_string.master_user_password.result
  }
  common_tenable_values = {
    engine   = local.engines_map[var.db_engine]
    endpoint = aws_db_instance.postgres_rds[0].address
    port     = var.db_port
    dbname   = var.db_username
    password = random_string.master_user_password.result
  }
}

resource "random_uuid" "shapshot_postfix" {}

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

  name_prefix             = format("%s-%s-%s", var.component_name, "master-secret", terraform.workspace)
  description             = "secret to manage superuser ${var.db_username} on ${format("%s-%s", var.component_name, terraform.workspace)} instance"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "users_secret" {

  for_each                = toset(var.db_users)
  name_prefix             = each.key == var.db_users ? "tenable-${format("%s-%s", var.component_name, terraform.workspace)}" : format("%s-%s", var.component_name, terraform.workspace)
  description             = "secret to manage user credential of ${each.key} on ${format("%s-%s", var.component_name, terraform.workspace)} instance"
  recovery_window_in_days = 0

}
resource "aws_secretsmanager_secret_version" "master_secret_value" {
  secret_id     = aws_secretsmanager_secret.master_secret.id
  secret_string = jsonencode(merge(local.common_secret_values, { username = var.db_username, password = random_string.master_user_password.result }))
}

# Secrets Manager for all application users that requires a password 
resource "aws_secretsmanager_secret_version" "user_secret_value" {

  for_each      = toset(keys(aws_secretsmanager_secret.users_secret))
  secret_id     = aws_secretsmanager_secret.users_secret[each.key].id
  secret_string = jsonencode(merge(local.common_tenable_values, { username = each.key, password = random_password.users_password[each.key].result }))
}

resource "aws_db_instance" "postgres_rds" {
  count = var.create_db_instance ? 1 : 0

  allocated_storage = var.db_storage == null ? 100 : var.db_storage
  engine            = var.db_engine == null ? "postgres" : var.db_engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  port              = var.db_port == null ? 5432 : var.db_port
  username          = var.db_username == null ? var.db_engine : var.db_username
  password          = random_string.master_user_password.result

  vpc_security_group_ids = compact(concat(aws_security_group.this.*.id, var.vpc_security_group_ids))
  identifier             = format("%s-%s", var.component_name, terraform.workspace)
  skip_final_snapshot    = var.skip_db_snapshot == null ? false : var.skip_db_snapshot
  publicly_accessible    = var.publicly_accessible == null ? false : var.publicly_accessible
  db_subnet_group_name   = aws_db_subnet_group.db_subnets[0].id
  multi_az               = var.multi_az == null ? true : var.multi_az
  tags                   = {}

  lifecycle {
    ignore_changes = [
      identifier,
      engine_version,
      engine,
      password
    ]
  }

}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = local.create_database && var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id
  description = coalesce(var.security_group_description, "Control traffic to/from RDS Aurora ${var.name}")

  tags = merge(var.tags, var.security_group_tags, { Name = var.name })
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "default_ingress" {
  count = local.create_database && var.create_security_group ? length(var.allowed_security_groups) : 0

  description = "From allowed SGs"

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = local.rds_security_group_id
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "cidr_ingress" {
  count = local.create_database && var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  description = "From allowed CIDRs"

  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = local.rds_security_group_id
}

resource "aws_security_group_rule" "egress" {
  for_each = local.create_database && var.create_security_group ? var.security_group_egress_rules : {}

  type              = "egress"
  from_port         = lookup(each.value, "from_port", var.db_port)
  to_port           = lookup(each.value, "to_port", var.db_port)
  protocol          = "tcp"
  security_group_id = local.rds_security_group_id


  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  description              = lookup(each.value, "description", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}

resource "aws_db_subnet_group" "db_subnets" {
  count       = var.create_db_instance ? 1 : 0
  name_prefix = format("%s-%s-%s", var.component_name, "db-subnets", terraform.workspace)
  subnet_ids  = var.db_subnets
  lifecycle {
    ignore_changes = [
      name_prefix,
    ]
  }
}

provider "postgresql" {

  alias            = "pgconnect"
  host             = aws_db_instance.postgres_rds[0].address
  port             = aws_db_instance.postgres_rds[0].port
  username         = var.db_username
  password         = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)["password"]
  superuser        = false
  sslmode          = "require"
  expected_version = aws_db_instance.postgres_rds[0].engine_version
  connect_timeout  = 15
}

resource "postgresql_database" "postgres" {

  for_each          = toset(var.databases_created == null ? ["tenable_db"] : var.databases_created)
  provider          = postgresql.pgconnect
  name              = each.key
  allow_connections = true
  depends_on        = [aws_db_instance.postgres_rds]
}

resource "postgresql_schema" "my_schema" {
  for_each = {
    for schema, value in var.schemas_list_owners : schema => value
    if(var.create_schema)
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
