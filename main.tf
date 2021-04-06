provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}


module "ingestion" {
  source = "./ingestion"
}

module "serving" {
  source = "./serving"
}