output "two_us_regions_with_zones" {
  description = "Outputs two random US regions with zones."
  value       = [for v in module.regions.regions : v if contains(random_shuffle.two_us_region_names_with_zones.result, v.name)]
}
