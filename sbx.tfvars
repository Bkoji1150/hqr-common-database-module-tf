
db_users = [
  "kojitechs",
  "max"
]

vpc_id = "vpc-0880cca64d0eb856d"

db_users_privileges = [
  {
    database   = "postgres"
    privileges = ["SELECT"]
    schema     = "public"
    type       = "table"
    user       = "kojitechs"
    objects    = []
  },
  {
    database   = "postgres"
    privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
    schema     = "public"
    type       = "table"
    user       = "kojitechs"
    objects    = []
  }
]

schemas_list_owners = [
  {
    database           = "postgres"
    name_of_theschema  = "kojitechs_schema"
    onwer              = "cypress_app"
    usage              = true
    role               = null
    with_create_object = true
    with_usage         = true
    role_name          = "cypress_app"
  }
]
