output "regions" {
  description = <<DESCRIPTION
A list of region objects subject to the filters supplied by input variables. Each region object contains the following attributes:

- `name` - The name of the region.
- `display_name` - The display name of the region.
- `paired_region_name` - The name of the region paired with this region. May be `null` if the region has no pair.
- `geography` - The geography of the region.
- `geography_group` - The geography group of the region.
- `zones` - A list of the availability zones in the region. Will be empty if the region does not support zones.
- `geo_code` - The geo code of the region. May be `null` if the region does not have a published geo code. Also known as a region short name.
- `short_name` - A calculated short name for the region, derived from the initials of the display name. This is not an official geo code and is provided for convenience where no geo code is available, but the geo code is used in resource naming.
DESCRIPTION
  value       = local.locations_filtered
}

output "regions_by_display_name" {
  description = "A map of region display names to region objects subject to the filters supplied by input variables. See `regions` output for more details."
  value       = local.regions_by_display_name
}

output "regions_by_geography" {
  description = "A map of geographies to a list of region objects subject to the filters supplied by input variables. See `regions` output for more details."
  value       = local.regions_by_geography
}

output "regions_by_geography_group" {
  description = "A map of geography groups to a list of region objects subject to the filters supplied by input variables. See `regions` output for more details."
  value       = local.regions_by_geography_group
}

output "regions_by_name" {
  description = "A map of region display names to region objects subject to the filters supplied by input variables. See `regions` output for more details."
  value       = local.regions_by_name
}

output "regions_by_name_or_display_name" {
  description = "A map of regions by either display names or name, to region objects subject to the filters supplied by input variables. See `regions` output for more details."
  value       = merge(local.regions_by_display_name, local.regions_by_name)
}

output "valid_region_display_names" {
  description = "A set of valid region display names subject to the filters supplied by input variables."
  value       = local.valid_region_display_names
}

output "valid_region_names" {
  description = "A set of valid region names subject to the filters supplied by input variables."
  value       = local.valid_region_names
}

output "valid_region_names_or_display_names" {
  description = "A set of valid region names or display names subject to the filters supplied by input variables."
  value       = local.valid_region_names_or_display_names
}
