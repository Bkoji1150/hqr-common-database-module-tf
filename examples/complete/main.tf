
terraform {
  required_version = "~> 1.1.5"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::${lookup(var.aws_account_id, terraform.workspace)}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = module.required_tags.aws_default_tags
  }
}

terraform {
  required_version = ">=1.1.5"

  backend "s3" {
    bucket = "hqr.common.database.module.kojitechs.tf"
    key    = "path/env"
    region = "us-east-1"
  }
}

module "required_tags" {
  source = "git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git"

  line_of_business        = var.line_of_business
  ado                     = var.ado
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = var.tech_poc_primary
  tech_poc_secondary      = var.tech_poc_secondary
  application             = "Database"
  builder                 = var.builder
  application_owner       = var.application_owner
  vpc                     = var.cell_name
  cell_name               = var.cell_name
  component_name          = format("%s-%s", var.component_name, terraform.workspace)

}


module "rds_module" {
  source = "git::git@github.com:Bkoji1150/hqr-common-database-module-tf.git"

  tier           = var.tier
  component_name = format("%s-%s", var.component_name, terraform.workspace)
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_users       = var.db_users
  db_storage     = 50

  publicly_accessible = true
  multi_az            = var.multi_az
  cidr_blocks_sg      = ["0.0.0.0/0"]
  vpc_id              = var.vpc_id
  db_subnets          = var.db_subnets
  db_port             = "5444"
  schemas_list_owners = var.schemas_list_owners
  db_username         = "kojitechs"
  db_users_privileges = var.db_users_privileges
  databases_created   = var.databases_created
}
