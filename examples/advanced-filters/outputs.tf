output "named_recommended_regions_with_azs" {
  value = module.regions_recommended_regions_with_azs.regions
}

output "not_recommended_regions_without_azs" {
  value = module.regions_not_recommended_regions_without_azs.regions
}
