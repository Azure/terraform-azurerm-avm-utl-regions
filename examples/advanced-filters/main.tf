terraform {
  required_version = "~> 1.6"
}


module "regions_not_recommended_regions_without_azs" {
  source = "../../"

  has_availability_zones = false
  is_recommended         = false
  recommended_filter     = false # disable legacy filter
}


module "regions_recommended_regions_with_azs" {
  source = "../../"

  enable_telemetry       = var.enable_telemetry
  has_availability_zones = true
  has_pair               = true
  is_recommended         = true
  recommended_filter     = false                                   # disable legacy filter
  region_filter          = ["uksouth", "Sweden Central", "ukwest"] # Will not return UK West due to AZ requirement
}
