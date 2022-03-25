db_users = [
  "max",
  "philo"
]

vpc_id = "vpc-0880cca64d0eb856d"

db_users_privileges = [
  {
    database   = "postgres"
    privileges = ["SELECT"]
    schema     = "public"
    type       = "table"
    user       = "max"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "philo"
    objects    = []
  }
]

schemas_list_owners = [
  {
    database           = "postgres"
    name_of_theschema  = "kojitechs_schema"
    onwer              = "kojitechs"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "kojitechs"
  }
]

db_subnets = ["subnet-00afe21bbbfe0d272", "subnet-098360d8df2c074a6", "subnet-0a8af057d94440f99"]
