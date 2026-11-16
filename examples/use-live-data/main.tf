terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
  }
}

module "regions" {
  source = "../../"

  location         = var.location
  enable_telemetry = var.enable_telemetry
  use_cached_data  = false
}
