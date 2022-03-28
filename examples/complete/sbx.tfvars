db_users = [
  "max",
  "philo",
  "opk"
]

myipp = ["71.163.242.34/32"]

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
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "opk_schema"
    type       = "table"
    user       = "opk"
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
  },
  {
    database           = "postgres"
    name_of_theschema  = "opk_schema"
    onwer              = "kojitechs"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "kojitechs"
  }
]
