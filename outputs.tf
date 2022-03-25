output "db_info" {
  description = "Output db information"
  value       = aws_db_instance.postgres_rds
  sensitive   = true
}
