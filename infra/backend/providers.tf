# Use same region and consistent tagging across stacks
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Stack     = "backend"
      Env       = "dev"
    }
  }
}
