variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(string)
  default = {
    prod = "735972722491"
    sbx  = "674293488770"
  }
}

variable "aws_region" {
  description = "Region to which thos code would be deployed to"
  type        = string
  default     = "us-east-1"
}

variable "line_of_business" {
  description = "Line of Business"
  type        = string
  default     = "Kojitechs"
}
variable "ado" {
  description = "Compainy name for this project"
  type        = string
  default     = "Kojitechs"
}
variable "tier" {
  type        = string
  description = "Canonical name of the application tier"
  default     = "WEB"
}

variable "cell_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = "APP"
}

variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "hqr-common-database"
}

variable "create_db_instance" {
  description = "Whether to create a database instance"
  type        = bool
  default     = true
}
variable "engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = "9.6"
}
variable "create_db_option_group" {
  description = "(Optional) Create a database option group"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "vpc id"
  type        = string

}
variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  default     = null
}

variable "create_random_password" {
  description = "Whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "db_users" {
  description = "List of all databases"
  type        = list(any)
  default     = []
}

variable "db_users_privileges" {
  description = <<-EOT
  If a user in this map does not also exist in the db_users list, it will be ignored.
  Example usage of db_users:
  ```db_users_privileges = [
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user1"
      type  = “example_type1”
      schema     = "example_schema1"
      privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
      objects    = [“example_object”]
    },
    {
      database  = "EXAMPLE POSTGRES"
      user       = “example_user2"
      type       = “example_type2”
      schema     = “example_schema2"
      privileges = [“SELECT”]
      objects    = []
    }
  ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    user       = string
    type       = string
    schema     = string
    privileges = list(string)
    objects    = list(string)
    database   = string
  }))
  default = []
}

variable "schemas_list_owners" {
  description = <<-EOT
  If a schemas in this map does not also exist in the onwers list, it will be ignored.
  Example usage of schemas:
  ```schemas = [
    {
      database   = "postgres"
      name_of_theschema = "EXAMPLE_PUBLIC"
      onwer = "EXAMPLE_POSTGRES"
      policy {
        usage = true/false # yes to grant usage on schema
        role = "ROLE/USER" # The role/user to which this schema would be granted access to
      }
        # app_releng can create new objects in the schema.  This is the role that
         # migrations are executed as.
      policy {
      with_create_object = true/false
      with_usage = true/false
      role_name  = "postgres" if false null
  }
      ]```
  Note: An empty objects list applies the privilege on all database objects matching the type provided.
  For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html
  EOT
  type = list(object({
    database           = string
    name_of_theschema  = string
    onwer              = string
    usage              = bool
    role               = string
    with_create_object = bool
    with_usage         = bool
    role_name          = string
  }))
}

variable "tenable_user" {
  description = "RDS Teneble users"
  type        = string
  default     = "postgres_aa2"
}


variable "db_clusters" {
  type        = map(any)
  description = "The AWS DB cluster reference"
  default = {
    engine     = "postgres"
    name       = "cypress_app"
    port       = 5432
    dbname     = "cypress_app"
    identifier = "hqr-database-reporting"
  }
}

variable "db_initial_id" {
  description = "database initail id"
  type        = string
  default     = "Blesses#default"
}

variable "service_name" {
  description = "Name of the service."
  type        = string
  default     = "reporting"
}

variable "databases_created" {
  description = "List of all databases Created!!!"
  type        = list(string)
  default     = ["my_db1", "cypress_test"]
}

variable "service_tier" {
  description = "Tier to deploy the service into. APP, WEB, or DATA"
  type        = string
  default     = "WEB"
}

# Required Tags variables
variable "application_owner" {
  description = "Email Group for the Application owner."
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "builder" {
  description = "Email for the builder of this infrastructure"
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "tech_poc_primary" {
  description = "Primary Point of Contact for Technical support for this service."
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "tech_poc_secondary" {
  description = "Secondary Point of Contact for Technical support for this service."
  type        = string
  default     = "kojibello058@gmail.com"
}


variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 0
}

variable "ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
  type        = bool
  default     = true
}


variable "random_password_length" {
  description = "(Optional) Length of random password to create. (default: 10)"
  type        = number
  default     = 10
}

variable "instance_class" {
  description = "hqr db instance class"
  type        = string
  default     = "db.m4.large"
}

variable "db_storage" {
  description = "Database storage in Gb"
  type        = string
  default     = 300
}

variable "skip_db_snapshot" {
  description = "skip snaption for hqr db instance"
  type        = bool
  default     = true
}
variable "multi_az" {
  description = "Enable multity az for hqr db instance"
  type        = bool
  default     = true
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}
