# locations is the source data set, either from a cache or live data.
locals {
  locations = [for loc in local.locations_merged : {
    display_name       = loc.display_name
    geography          = loc.geography
    geography_group    = loc.geography_group
    name               = loc.name
    paired_region_name = loc.paired_region_name
    recommended        = loc.recommended
    zones              = loc.zones
    geo_code           = try(local.geo_codes_by_name[loc.name], null)
    short_name         = join("", [for word in split(" ", loc.display_name) : lower(substr(word, 0, 1))])
  }]
  locations_merged = var.use_cached_data ? local.cached_locations_list : local.live_locations_list
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
