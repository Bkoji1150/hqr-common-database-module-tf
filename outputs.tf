output "db_info" {
  description = "Output db information"
  value       = aws_db_instance.postgres_rds
  sensitive   = true
}

output "db_secrets" {
  value     = jsondecode(aws_secretsmanager_secret_version.master_secret_value.secret_string)
  sensitive = true
}
