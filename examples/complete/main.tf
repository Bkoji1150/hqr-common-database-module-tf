
locals {
  sub = slice(local.public_subnets, 0, 1)
}
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

data "terraform_remote_state" "operational_environment" {
  backend = "s3"

  config = {
    region = "us-east-1"
    bucket = "operational.vpc.tf.kojitechs"
    key    = format("env:/%s/path/env", lower(terraform.workspace))
  }
}


locals {
  operational_state   = data.terraform_remote_state.operational_environment.outputs
  vpc_id              = local.operational_state.vpc_id
  public_subnet_ids   = local.operational_state.public_subnets
  private_subnets_ids = local.operational_state.private_subnets
  public_subnets      = local.operational_state.public_subnet_cidr_block

}

resource "aws_security_group" "db_sg" {
  name        = format("%s-%s-%s", var.component_name, "db-sg", terraform.workspace)
  description = "Allow inbound traffic to ${format("%s-%s", var.component_name, terraform.workspace)} db"
  vpc_id      = local.vpc_id
  ingress {
    description = "Allow traffic to db port from port ${var.port}"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.myipp
  }
  ingress {
    description = "Allow traffic to db port from port ${var.port}"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.subnet_cidr_block
  }
  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
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
  source = "../.." #git::git@github.com:Bkoji1150/hqr-common-database-module-tf.git"

  tier           = var.tier
  component_name = var.component_name
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_users       = var.db_users
  db_storage     = 50
  publicly_accessible = true
  multi_az            = var.multi_az
#  vpc_security_group_ids = [aws_security_group.db_sg.id]
  security_group = [aws_security_group.db_sg.id]
  allowed_cidr_blocks = var.myipp
  vpc_id              = local.vpc_id
  db_subnets          = slice(local.public_subnet_ids, 0, 3)
  db_port             = var.port
  schemas_list_owners = var.schemas_list_owners
  db_username         = "kojitechs"
  db_users_privileges = var.db_users_privileges
  databases_created   = var.databases_created
  subnets_lambda = local.public_subnets
}

