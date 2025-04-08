# Implement an anti-coprruption layer to transform the data from the Azure API into a format that is easier to work with in the rest of the module.
locals {
  cached_locations_list = tolist([
    for location in local.locations_cached.value : {
      display_name       = location.displayName
      geography          = location.metadata.geography
      geography_group    = location.metadata.geographyGroup
      name               = location.name
      paired_region_name = try(one(location.metadata.pairedRegion).name, null)
      recommended        = location.metadata.regionCategory == "Recommended"
      zones              = try([for zone in location.availabilityZoneMappings : tonumber(zone.logicalZone)], tolist(null))
      geo_code           = try(local.geo_codes_by_name[location.name], null)
    } if location.metadata.regionType == "Physical"
  ])
}
