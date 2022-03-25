# hqr-common-database-module-tf
This repository creates infrastructure to Database module See [MIGRATION.md](https://github.com/Bkoji1150/hqr-common-database-module-tf.git) for more context.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1.5 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_postgresql.pgconnect"></a> [postgresql.pgconnect](#provider\_postgresql.pgconnect) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_Security_module"></a> [Security\_module](#module\_Security\_module) | git::git@github.com:Bkoji1150/hqr-security-group.git//Sg | n/a |
| <a name="module_required_tags"></a> [required\_tags](#module\_required\_tags) | git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.postgres_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_secretsmanager_secret.master_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.users_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.master_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.user_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [postgresql_database.postgres](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_grant.user_privileges](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/grant) | resource |
| [postgresql_role.users](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/role) | resource |
| [postgresql_schema.my_schema](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |
| [random_password.users_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.master_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_uuid.shapshot_postfix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ado"></a> [ado](#input\_ado) | Compainy name for this project | `string` | `"Kojitechs"` | no |
| <a name="input_application_owner"></a> [application\_owner](#input\_application\_owner) | Email Group for the Application owner. | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Environment this template would be deployed to | `map(string)` | <pre>{<br>  "prod": "735972722491",<br>  "sbx": "674293488770"<br>}</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region to which thos code would be deployed to | `string` | `"us-east-1"` | no |
| <a name="input_builder"></a> [builder](#input\_builder) | Email for the builder of this infrastructure | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | Specifies the identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_cell_name"></a> [cell\_name](#input\_cell\_name) | Name of the ECS cluster to deploy the service into. | `string` | `"APP"` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | Name of the component. | `string` | `"hqr-common-database"` | no |
| <a name="input_create_db_instance"></a> [create\_db\_instance](#input\_create\_db\_instance) | Whether to create a database instance | `bool` | `true` | no |
| <a name="input_create_db_option_group"></a> [create\_db\_option\_group](#input\_create\_db\_option\_group) | (Optional) Create a database option group | `bool` | `true` | no |
| <a name="input_create_random_password"></a> [create\_random\_password](#input\_create\_random\_password) | Whether to create random password for RDS primary cluster | `bool` | `false` | no |
| <a name="input_databases_created"></a> [databases\_created](#input\_databases\_created) | List of all databases Created!!! | `list(string)` | <pre>[<br>  "my_db1",<br>  "cypress_test"<br>]</pre> | no |
| <a name="input_db_clusters"></a> [db\_clusters](#input\_db\_clusters) | The AWS DB cluster reference | `map(any)` | <pre>{<br>  "dbname": "cypress_app",<br>  "engine": "postgres",<br>  "identifier": "hqr-database-reporting",<br>  "name": "cypress_app",<br>  "port": 5432<br>}</pre> | no |
| <a name="input_db_initial_id"></a> [db\_initial\_id](#input\_db\_initial\_id) | database initail id | `string` | `"Blesses#default"` | no |
| <a name="input_db_storage"></a> [db\_storage](#input\_db\_storage) | Database storage in Gb | `string` | `300` | no |
| <a name="input_db_users"></a> [db\_users](#input\_db\_users) | List of all databases | `list(any)` | `[]` | no |
| <a name="input_db_users_privileges"></a> [db\_users\_privileges](#input\_db\_users\_privileges) | If a user in this map does not also exist in the db\_users list, it will be ignored.<br>Example usage of db\_users:<pre>db_users_privileges = [<br>  {<br>    database  = "EXAMPLE POSTGRES"<br>    user       = “example_user1"<br>    type  = “example_type1”<br>    schema     = "example_schema1"<br>    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]<br>    objects    = [“example_object”]<br>  },<br>  {<br>    database  = "EXAMPLE POSTGRES"<br>    user       = “example_user2"<br>    type       = “example_type2”<br>    schema     = “example_schema2"<br>    privileges = [“SELECT”]<br>    objects    = []<br>  }<br>]</pre>Note: An empty objects list applies the privilege on all database objects matching the type provided.<br>For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html | <pre>list(object({<br>    user       = string<br>    type       = string<br>    schema     = string<br>    privileges = list(string)<br>    objects    = list(string)<br>    database   = string<br>  }))</pre> | `[]` | no |
| <a name="input_delete_automated_backups"></a> [delete\_automated\_backups](#input\_delete\_automated\_backups) | Specifies whether to remove automated backups immediately after the DB instance is deleted | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specifies the major version of the engine that this option group should be associated with | `string` | `"9.6"` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | hqr db instance class | `string` | `"db.m4.large"` | no |
| <a name="input_line_of_business"></a> [line\_of\_business](#input\_line\_of\_business) | Line of Business | `string` | `"Kojitechs"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Specifies the value for Storage Autoscaling | `number` | `0` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Enable multity az for hqr db instance | `bool` | `true` | no |
| <a name="input_password"></a> [password](#input\_password) | Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file | `string` | `null` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | (Optional) Length of random password to create. (default: 10) | `number` | `10` | no |
| <a name="input_schemas_list_owners"></a> [schemas\_list\_owners](#input\_schemas\_list\_owners) | If a schemas in this map does not also exist in the onwers list, it will be ignored.<br>Example usage of schemas:<pre>schemas = [<br>  {<br>    database   = "postgres"<br>    name_of_theschema = "EXAMPLE_PUBLIC"<br>    onwer = "EXAMPLE_POSTGRES"<br>    policy {<br>      usage = true/false # yes to grant usage on schema<br>      role = "ROLE/USER" # The role/user to which this schema would be granted access to<br>    }<br>      # app_releng can create new objects in the schema.  This is the role that<br>       # migrations are executed as.<br>    policy {<br>    with_create_object = true/false<br>    with_usage = true/false<br>    role_name  = "postgres" if false null<br>}<br>    ]</pre>Note: An empty objects list applies the privilege on all database objects matching the type provided.<br>For information regarding types and privileges, refer to: https://www.postgresql.org/docs/13/ddl-priv.html | <pre>list(object({<br>    database           = string<br>    name_of_theschema  = string<br>    onwer              = string<br>    usage              = bool<br>    role               = string<br>    with_create_object = bool<br>    with_usage         = bool<br>    role_name          = string<br>  }))</pre> | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service. | `string` | `"reporting"` | no |
| <a name="input_service_tier"></a> [service\_tier](#input\_service\_tier) | Tier to deploy the service into. APP, WEB, or DATA | `string` | `"WEB"` | no |
| <a name="input_skip_db_snapshot"></a> [skip\_db\_snapshot](#input\_skip\_db\_snapshot) | skip snaption for hqr db instance | `bool` | `true` | no |
| <a name="input_tech_poc_primary"></a> [tech\_poc\_primary](#input\_tech\_poc\_primary) | Primary Point of Contact for Technical support for this service. | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_tech_poc_secondary"></a> [tech\_poc\_secondary](#input\_tech\_poc\_secondary) | Secondary Point of Contact for Technical support for this service. | `string` | `"kojibello058@gmail.com"` | no |
| <a name="input_tenable_user"></a> [tenable\_user](#input\_tenable\_user) | RDS Teneble users | `string` | `"postgres_aa2"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Canonical name of the application tier | `string` | `"WEB"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
