terraform {
  required_version = "~> 1.6"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

module "regions" {
  source = "../../"

  enable_telemetry = var.enable_telemetry
  use_cached_data  = true
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

