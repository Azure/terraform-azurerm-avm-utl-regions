# Implement an anti-coprruption layer to transform the data from the Azure API into a format that is easier to work with in the rest of the module.
locals {
  cached_locations_list = tolist([
    for location in module.cached_data.locations_cached.value : {
      display_name       = location.displayName
      geography          = location.metadata.geography
      geography_group    = lookup(location.metadata, "geographyGroup", null)
      name               = location.name
      paired_region_name = try(one(location.metadata.pairedRegion).name, null)
      recommended        = location.metadata.regionCategory == "Recommended"
      zones              = try([for zone in location.availabilityZoneMappings : tonumber(zone.logicalZone)], tolist(null))
    } if location.metadata.regionType == "Physical"
  ])
}
