output "random_region" {
  value = module.regions.regions[random_integer.region_index.result]
}
