terraform {
  required_version = "~> 1.6"

  required_providers {
  }
}

module "regions" {
  source = "../../"

  enable_telemetry = false
  use_cached_data  = false
}
