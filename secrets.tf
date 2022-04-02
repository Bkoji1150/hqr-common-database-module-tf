locals {
   filename           = var.rotation_type == "single" ? "SecretsManagerRDSMySQLRotationSingleUser.zip" : "SecretsManagerRDSMySQLRotationMultiUser.zip"
  lambda_description = var.rotation_type == "single" ? "Conducts an AWS SecretsManager secret rotation for RDS MySQL using single user rotation scheme" : "Conducts an AWS SecretsManager secret rotation for RDS MySQL using multi user rotation scheme"
  secret_string_single_bare = {
    engine   = var.db_engine
     host = aws_db_instance.postgres_rds[0].address
    username   = var.db_username
    dbname = "postgres"
    port     = var.db_port
    password = random_string.master_user_password.result
  }
  secret_string_single_replica = {
     engine   = var.db_engine
     host = aws_db_instance.postgres_rds[0].address
    username   = var.db_username
    dbname = "postgres"
    port     = var.db_port
    password = random_string.master_user_password.result
  }
  secret_string_single = var.mysql_replicahost == null ? local.secret_string_single_bare : local.secret_string_single_replica

  secret_string_multi_bare = {
    engine   = var.db_engine
     host = aws_db_instance.postgres_rds[0].address
    username   = var.db_username
    dbname = "postgres"
    port     = var.db_port
    password = random_string.master_user_password.result
  }
  secret_string_multi_replica = {
     engine   = var.db_engine
     host = aws_db_instance.postgres_rds[0].address
    username   = var.db_username
    dbname = "postgres"
    port     = var.db_port
    password = random_string.master_user_password.result
  }
    common_tenable_valuess = {
    engine   = "postgres"
    host = aws_db_instance.postgres_rds[0].address
    port     = var.db_port
    dbname   = var.db_username
    password = random_string.master_user_password.result
  }
  secret_string_multi = random_string.master_user_password.result == null ? local.secret_string_multi_bare : local.secret_string_multi_replica
}

resource "aws_iam_role" "default" {
  name               = "${var.component_name}-password_rotation"
  assume_role_policy = data.aws_iam_policy_document.service.json

}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-vpc" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy0" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerRDSMySQLRotationSingleUserRolePolicy0"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy0.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy1" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerRDSMySQLRotationSingleUserRolePolicy1"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy1.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationSingleUserRolePolicy2" {
  count  = var.rotation_type == "single" ? 1 : 0
  name   = "SecretsManagerRDSMySQLRotationSingleUserRolePolicy2"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationSingleUserRolePolicy2.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationMultiUserRolePolicy0" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerRDSMySQLRotationMultiUserRolePolicy0"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationMultiUserRolePolicy0.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationMultiUserRolePolicy1" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerRDSMySQLRotationMultiUserRolePolicy1"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationMultiUserRolePolicy1.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationMultiUserRolePolicy2" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerRDSMySQLRotationMultiUserRolePolicy2"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationMultiUserRolePolicy2.json
}

resource "aws_iam_role_policy" "SecretsManagerRDSMySQLRotationMultiUserRolePolicy4" {
  count  = var.rotation_type == "single" ? 0 : 1
  name   = "SecretsManagerRDSMySQLRotationMultiUserRolePolicy4"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.SecretsManagerRDSMySQLRotationMultiUserRolePolicy4.json
}

resource "aws_lambda_function" "default" {
  description      = local.lambda_description
  filename         =  "${path.cwd}/functions/${local.filename}"
  source_code_hash = filebase64sha256("${path.cwd}/functions/${local.filename}")
  function_name    = "${var.component_name}-password_rotation"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.7"
  timeout          = 30
  role             = aws_iam_role.default.arn
  vpc_config {
    subnet_ids         = var.subnets_lambda
    security_group_ids = var.security_group
  }
  environment {
    variables = { #https://docs.aws.amazon.com/general/latest/gr/rande.html#asm_region
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }

}

resource "aws_lambda_permission" "default" {
  function_name = aws_lambda_function.default.function_name
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_kms_key" "default" {
  description         = "Key for Secrets Manager secret [${var.db_username}]"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "default" {
  name          = format("%s/%s", "alias",  var.component_name)
  target_key_id = aws_kms_key.default.key_id
}

resource "aws_secretsmanager_secret" "default" {
  name        = format("%s-%s", var.component_name, var.db_username )
  description = "Username and password for RDS user [${var.db_username}]."
  kms_key_id  = aws_kms_key.default.key_id

  #policy      = # TODO
}

resource "aws_secretsmanager_secret_rotation" "default" {
  secret_id           = aws_secretsmanager_secret.default.id
  rotation_lambda_arn = aws_lambda_function.default.arn
  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = jsonencode(var.rotation_type == "single" ? local.secret_string_single : local.secret_string_multi)

  # Changes to the password in Terraform should not trigger a change in state
  # to Secrets Manager as this could cause a loss of access to the target RDS
  # instance.
  # In other words, once Secrets Manager has managed to rotate the password,
  # Terraform should no longer attempt to apply a new password.
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

