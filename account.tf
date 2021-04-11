# This file declares variables for authorization and others account's info. For credencials, 
# no default value is assigned. To do so, define a terraform variable file (*.tfvars) and
# explicitly reference it on apply using -var-file option, eg:
#     terraform apply -var-file="/path/to/varfile.tfvars"

## CREDENTIAL DEFINITION ##
variable "access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Access Key"
}

## ACCOUNT INFO DEFINITION ##
variable "account_alias" {
  default     = "dev"
  description = "AWS account alias"
}

variable "account_id" {
  default     = "123456789"
  description = "AWS account id"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}
