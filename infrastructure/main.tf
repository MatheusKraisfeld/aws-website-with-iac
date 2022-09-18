locals {
  prefix = "${terraform.workspace}-${var.prefix}"
  common_tags = {
    Project      = "aws-website-with-iac",
    ManagedBy    = "Matheus Kraisfeld"
    Owner        = "Matheus Kraisfeld"
    BusinessUnit = "Data"
    Billing      = "Infrastructure"
    Environment  = terraform.workspace
    UserEmail    = "matheuskraisfeld@gmail.com"
  }
}