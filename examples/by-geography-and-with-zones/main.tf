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

  availability_zones_filter = true
  enable_telemetry          = var.enable_telemetry
  geography_filter          = "United States"
}


resource "random_shuffle" "two_us_region_names_with_zones" {
  input        = module.regions.valid_region_names
  result_count = 2
}

