# locations is the source data set, either from a cache or live data.
locals {
  geo_codes = {
    for loc in local.locations_merged : loc.name => {
      geo_code            = try(local.geo_codes_by_name[loc.name], null)
      geo_code_calculated = join("", [for word in split(" ", loc.display_name) : lower(substr(word, 0, 1))])
      geo_code_found      = try(local.geo_codes_by_name[loc.name], null) != null
    }
  }
  locations = [for loc in local.locations_merged : {
    display_name        = loc.display_name
    geography           = loc.geography
    geography_group     = loc.geography_group
    name                = loc.name
    paired_region_name  = loc.paired_region_name
    recommended         = loc.recommended
    zones               = loc.zones
    geo_code            = coalesce(local.geo_codes[loc.name].geo_code, var.geo_code_fallback_to_calculated_enabled ? local.geo_codes[loc.name].geo_code_calculated : null)
    geo_code_calculated = local.geo_codes[loc.name].geo_code_calculated
    geo_code_found      = local.geo_codes[loc.name].geo_code_found
  }]
  locations_merged = var.use_cached_data ? local.cached_locations_list : local.live_locations_list
}

# Use set theory for the filters...
locals {
  # A set of all location names to use if no filter is applied.
  locations_all_names = toset([for v in local.locations : v.name])
  # A set of location names that match the geography filter.
  locations_geography_filter = var.geography_filter != null ? toset([for v in local.locations : v.name if v.geography == var.geography_filter]) : local.locations_all_names
  # A set of location names that match the geography group filter.
  locations_geography_group_filter = var.geography_group_filter != null ? toset([for v in local.locations : v.name if v.geography_group == var.geography_group_filter]) : local.locations_all_names
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
    local.locations_final_paired_region_filter,
    local.locations_final_availability_zones_filter,
    local.locations_final_is_recommended_filter,
    local.locations_region_filter
  )
}

# These locals create maps of the regions based on different attributes.
locals {
  geo_groups              = distinct([for v in local.locations_filtered : v.geography_group if v.geography_group != null])
  geos                    = distinct([for v in local.locations_filtered : v.geography if v.geography != null])
  regions_by_display_name = { for v in local.locations_filtered : v.display_name => v }
  regions_by_geography = {
    for geo in local.geos : geo => [
      for v in local.locations_filtered : v if v.geography == geo
    ]
  }
  regions_by_geography_group = {
    for geo_group in local.geo_groups : geo_group => [
      for v in local.locations_filtered : v if v.geography_group == geo_group
    ]
  }
  regions_by_name = { for v in local.locations_filtered : v.name => v }
}

# These locals are the valid region names and display names.
locals {
  valid_region_display_names          = sort(keys(local.regions_by_display_name))
  valid_region_names                  = sort(keys(local.regions_by_name))
  valid_region_names_or_display_names = sort(setunion(local.valid_region_names, local.valid_region_display_names))
}
