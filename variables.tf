variable "aws_account_id" {
  description = "Environment this template would be deployed to"
  type        = map(any)
  default = {
    PROD = "735972722491"
    SBX  = "674293488770"
  }
}

variable "line_of_business" {
  description = "Line of Business"
  default     = "HQR"
}

variable "tier" {
  description = "Canonical name of the application tier"
  type        = string
  default     = "WEB"
}

variable "cell_name" {
  description = "Name of the ECS cluster to deploy the service into."
  type        = string
  default     = "DATA"
}

variable "component_name" {
  description = "Name of the component."
  type        = string
  default     = "hqr-common-database-module"
}
