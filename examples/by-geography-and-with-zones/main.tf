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
  source                    = "../../"
  enable_telemetry          = var.enable_telemetry
  availability_zones_filter = true
  geography_filter          = "United States"
}


resource "random_shuffle" "two_us_region_names_with_zones" {
  input        = module.regions.valid_region_names
  result_count = 2
}

output "two_us_regions_with_zones" {
  value       = [for v in module.regions.regions : v if contains(random_shuffle.two_us_region_names_with_zones.result, v.name)]
  description = "Outputs two random US regions with zones."
}
