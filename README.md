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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_required_tags"></a> [required\_tags](#module\_required\_tags) | git::git@github.com:Bkoji1150/kojitechs-tf-aws-required-tags.git | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Environment this template would be deployed to | `map(any)` | <pre>{<br>  "PROD": "735972722491",<br>  "SBX": "674293488770"<br>}</pre> | no |
| <a name="input_cell_name"></a> [cell\_name](#input\_cell\_name) | Name of the ECS cluster to deploy the service into. | `string` | `"DATA"` | no |
| <a name="input_component_name"></a> [component\_name](#input\_component\_name) | Name of the component. | `string` | `"hqr-common-database-module"` | no |
| <a name="input_line_of_business"></a> [line\_of\_business](#input\_line\_of\_business) | Line of Business | `string` | `"HQR"` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Canonical name of the application tier | `string` | `"WEB"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
