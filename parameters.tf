# This file declares the authorization variables, although, it doesn't assign any
# value to them. # To do so, define a terraform variable file (*.tfvars) and explicitly
# reference it on apply using -var-file option, eg:
#     terraform apply -var-file="/path/to/varfile.tfvars"
variable access_key {
  type        = string
  description = "AWS Access Key"
}

variable secret_key {
  type        = string
  description = "AWS Secret Access Key"
}

# Parameters definition
variable region {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}
