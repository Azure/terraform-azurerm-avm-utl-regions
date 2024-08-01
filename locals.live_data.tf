# Implement an anti-coprruption layer to transform the data from the Azure API into a format that is easier to work with in the rest of the module.
locals {
  live_locations_list = !var.use_cached_data ? [
    for location in jsondecode(data.azapi_resource_action.locations[0].output).value : {
      display_name       = location.displayName
      geography          = location.metadata.geography
      geography_group    = location.metadata.geographyGroup
      name               = location.name
      paired_region_name = try(one(location.metadata.pairedRegion).name, null)
      recommended        = location.metadata.regionCategory == "Recommended"
      zones              = try([for zone in location.availabilityZoneMappings : tonumber(zone.logicalZone)], tolist(null))
    } if location.metadata.regionType == "Physical"
  ] : null
}
