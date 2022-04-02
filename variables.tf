variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(string)
  default = {
    prod = "735972722491"
    sbx  = "674293488770"
  }
}

variable "publicly_accessible" {
  description = "Make database public"
  type        = bool
  default     = false
}

variable "line_of_business" {
  description = "Line of Business"
  type        = string
  default     = null
}
variable "ado" {
  description = "Compainy name for this project"
  type        = string
  default     = null
}
variable "tier" {
  type        = string
  description = "Canonical name of the application tier"
  default     = null
}

variable "cell_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = null
}

variable "component_name" {
  description = "Name of the component."
  type        = string
}

variable "name" {
  description = "Name used across resources created"
  type        = string
  default     = ""
}

variable "create_schema" {
  description = "Create schema?"
  type        = bool
  default     = true
}
variable "create_db_instance" {
  description = "Whether to create a database instance"
  type        = bool
  default     = true
}
variable "engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string

}

variable "create_db_option_group" {
  description = "(Optional) Create a database option group"
  type        = bool
  default     = true
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
  default     = null
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
  default = [{
    user       = "postgres"
    type       = "table"
    schema     = "tenable_schema"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    objects    = []
    database   = "postgres"
  }]
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
  default = [
    {
      database           = "postgres"
      name_of_theschema  = "tenable_schema"
      onwer              = "postgres"
      usage              = true
      role               = null
      with_create_object = true
      with_usage         = true
      role_name          = "postgres"
  }]
}

variable "create_database" {
  description = "Whether cluster should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"

  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Determines whether to create security group for RDS cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = ""
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = null
}

variable "security_group_tags" {
  description = "Additional tags for the security group"
  type        = map(string)
  default     = {}
}

variable "allowed_security_groups" {
  description = "A list of Security Group ID's to allow access to"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks which are allowed to access the database"
  type        = list(string)
  default     = []
}

variable "security_group_egress_rules" {
  description = "A map of security group egress rule defintions to add to the security group created"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "application_owner" {
  description = "Email Group for the Application owner."
  type        = string
  default     = "kojibello058@gmail.com"
}

variable "databases_created" {
  description = "List of all databases Created by postgres provider!!!"
  type        = list(string)
  default     = ["tenable"]
}

# Required Tags variables


variable "builder" {
  description = "Email for the builder of this infrastructure"
  type        = string
  default     = null
}

variable "tech_poc_primary" {
  description = "Primary Point of Contact for Technical support for this service."
  type        = string
  default     = null
}

variable "tech_poc_secondary" {
  description = "Secondary Point of Contact for Technical support for this service."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "hqr db instance class"
  type        = string
}

variable "db_storage" {
  description = "Database storage in Gb"
  type        = string
  default     = null
}

variable "skip_db_snapshot" {
  description = "skip snaption for hqr db instance"
  type        = bool
  default     = true
}
variable "multi_az" {
  description = "Enable multity az for hqr db instance"
  type        = bool
  default     = null
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_subnets" {
  description = "The database db sunbet to use"
  type        = list(any)
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}
