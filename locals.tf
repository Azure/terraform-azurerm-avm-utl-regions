# These locals filter the API output based on the input variables.
locals {
  locations                           = var.use_cached_data ? local.cached_locations_list : local.live_locations_list
  locations_availability_zones_filter = var.availability_zones_filter ? [for v in local.locations_recommended_filter : v if v.zones != null] : local.locations_recommended_filter
  locations_filtered                  = local.locations_geography_group_filter
  locations_geography_filter          = var.geography_filter != null ? [for v in local.locations_availability_zones_filter : v if v.geography == var.geography_filter] : local.locations_availability_zones_filter
  locations_geography_group_filter    = var.geography_group_filter != null ? [for v in local.locations_geography_filter : v if v.geography_group == var.geography_group_filter] : local.locations_geography_filter
  locations_recommended_filter        = var.recommended_filter ? [for v in local.locations : v if v.recommended] : local.locations
}

# These locals create maps of the regions based on different attributes.
locals {
  geo_groups              = distinct([for v in local.locations_filtered : v.geography_group])
  geos                    = distinct([for v in local.locations_filtered : v.geography])
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
  valid_region_display_names          = toset(keys(local.regions_by_display_name))
  valid_region_names                  = toset(keys(local.regions_by_name))
  valid_region_names_or_display_names = setunion(local.valid_region_names, local.valid_region_display_names)
}
