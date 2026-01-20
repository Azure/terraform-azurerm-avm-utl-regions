# Use set theory for the filters...
locals {
  # A set of all location names to use if no filter is applied.
  locations_all_names = toset([for v in local.locations : v.name])
  # A set of location names that match the geography filter.
  locations_geography_filter = var.geography_filter != null ? toset([for v in local.locations : v.name if v.geography == var.geography_filter]) : local.locations_all_names
  # Folks can now specify multiple geographies or geography groups to filter by.
  locations_geography_filters = var.geography_filters != null ? toset([for v in local.locations : v.name if contains(var.geography_filters, v.geography)]) : local.locations_all_names
  # A set of location names that match the geography group filter.
  locations_geography_group_filter  = var.geography_group_filter != null ? toset([for v in local.locations : v.name if v.geography_group == var.geography_group_filter]) : local.locations_all_names
  locations_geography_group_filters = var.geography_group_filters != null ? toset([for v in local.locations : v.name if contains(var.geography_group_filters, v.geography_group)]) : local.locations_all_names
  # Filter name by regex
  locations_name_regex_filter = var.region_name_regex != null ? toset([for v in local.locations : v.name if can(regex(var.region_name_regex, v.name))]) : local.locations_all_names
  # Filter by region names or display names.
  locations_region_filter = var.region_filter != null ? toset([for v in local.locations : v.name if contains(var.region_filter, v.name) || contains(var.region_filter, v.display_name)]) : local.locations_all_names
}

# has paired regions can be set to true, false or null.
locals {
  locations_final_paired_region_filter  = var.has_pair == null ? local.locations_all_names : var.has_pair ? local.locations_has_paired_region_filter : local.locations_no_has_paired_region_filter
  locations_has_paired_region_filter    = toset([for v in local.locations : v.name if v.paired_region_name != null])
  locations_no_has_paired_region_filter = setsubtract(local.locations_all_names, local.locations_has_paired_region_filter)
}

# has availability zones can be set to true, false or null.
locals {
  locations_final_availability_zones_filter  = var.has_availability_zones == null ? local.locations_all_names : var.has_availability_zones ? local.locations_has_availability_zones_filter : local.locations_no_has_availability_zones_filter
  locations_has_availability_zones_filter    = toset([for v in local.locations : v.name if v.zones != null])
  locations_no_has_availability_zones_filter = setsubtract(local.locations_all_names, local.locations_has_availability_zones_filter)
}

# is recommended can be set to true, false or null.
locals {
  locations_final_is_recommended_filter = var.is_recommended == null ? local.locations_all_names : var.is_recommended ? local.locations_is_recommended_filter : local.locations_no_is_recommended_filter
  locations_is_recommended_filter       = toset([for v in local.locations : v.name if v.recommended])
  locations_no_is_recommended_filter    = setsubtract(local.locations_all_names, local.locations_is_recommended_filter)
}

# Use setintersection to filter the locations based on the above sets.
# This will create a new list of locations that match all the filters.
locals {
  # A list of locations that match the filtered names.
  locations_filtered = [for v in local.locations : v if contains(local.locations_filtered_names, v.name)]
  locations_filtered_names = setintersection(
    local.locations_geography_filter,
    local.locations_geography_group_filter,
    local.locations_geography_filters,
    local.locations_geography_group_filters,
    local.locations_final_paired_region_filter,
    local.locations_final_availability_zones_filter,
    local.locations_final_is_recommended_filter,
    local.locations_region_filter,
    local.locations_name_regex_filter,
  )
}
