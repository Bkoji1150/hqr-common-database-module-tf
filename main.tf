

terraform {
  required_version = "~> 1.1.5"
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/Role_For-S3_Creation"
  }
  default_tags {
    tags = local.default_tags
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

locals {
  default_tags = module.required_tags.aws_default_tags
}

module "required_tags" {
  source = "git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git"

  line_of_business        = var.line_of_business
  ado                     = "Kojitechs"
  tier                    = var.tier
  operational_environment = upper(terraform.workspace)
  tech_poc_primary        = "database@Kojitechs.io"
  tech_poc_secondary      = "database@Kojitechs.io"
  application             = "Database"
  builder                 = "kojibello058@gmail.com"
  application_owner       = "Analytics@Kojitechs.io"
  vpc                     = "APP"
  cell_name               = var.cell_name
  component_name          = var.component_name
}
