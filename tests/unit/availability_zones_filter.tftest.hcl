mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test availability zones filter (tri-state: true/false/null)
override_module {
  target = module.cached_data
  outputs = {
    locations_cached = {
      value = [
        {
          availabilityZoneMappings = [
            {
              logicalZone  = "1",
              physicalZone = "eastus-az1"
            },
            {
              logicalZone  = "2",
              physicalZone = "eastus-az2"
            },
            {
              logicalZone  = "3",
              physicalZone = "eastus-az3"
            }
          ],
          displayName = "East US",
          id          = "/subscriptions/test/locations/eastus",
          metadata = {
            geography      = "United States",
            geographyGroup = "US",
            latitude       = "37.3719",
            longitude      = "-79.8164",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/westus",
                name = "westus"
              }
            ],
            physicalLocation = "Virginia",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "eastus",
          regionalDisplayName = "(US) East US",
          type                = "Region"
        },
        {
          displayName = "West US",
          id          = "/subscriptions/test/locations/westus",
          metadata = {
            geography      = "United States",
            geographyGroup = "US",
            latitude       = "34.0522",
            longitude      = "-118.2437",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/eastus",
                name = "eastus"
              }
            ],
            physicalLocation = "California",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "westus",
          regionalDisplayName = "(US) West US",
          type                = "Region"
        },
        {
          availabilityZoneMappings = [
            {
              logicalZone  = "1",
              physicalZone = "northeurope-az1"
            },
            {
              logicalZone  = "2",
              physicalZone = "northeurope-az2"
            }
          ],
          displayName = "North Europe",
          id          = "/subscriptions/test/locations/northeurope",
          metadata = {
            geography      = "Europe",
            geographyGroup = "Europe",
            latitude       = "53.3478",
            longitude      = "-6.2597",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/westeurope",
                name = "westeurope"
              }
            ],
            physicalLocation = "Ireland",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "northeurope",
          regionalDisplayName = "(Europe) North Europe",
          type                = "Region"
        },
        {
          displayName = "West Europe",
          id          = "/subscriptions/test/locations/westeurope",
          metadata = {
            geography      = "Europe",
            geographyGroup = "Europe",
            latitude       = "52.3667",
            longitude      = "4.8945",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/northeurope",
                name = "northeurope"
              }
            ],
            physicalLocation = "Netherlands",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "westeurope",
          regionalDisplayName = "(Europe) West Europe",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "has_availability_zones_true" {
  command = apply

  variables {
    has_availability_zones = true
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions with availability zones"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.zones != null && length(r.zones) > 0])
    error_message = "All returned regions should have availability zones"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region (has zones)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should contain northeurope region (has zones)"
  }
}

run "has_availability_zones_false" {
  command = apply

  variables {
    has_availability_zones = false
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions without availability zones"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.zones == null || length(r.zones) == 0])
    error_message = "All returned regions should not have availability zones"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus region (no zones)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westeurope")
    error_message = "Should contain westeurope region (no zones)"
  }
}

run "has_availability_zones_null" {
  command = apply

  variables {
    has_availability_zones = null
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Should return all 4 regions when availability zones filter is null"
  }

  assert {
    condition     = length(setintersection(toset([for r in output.regions : r.name]), toset(["eastus", "westus", "northeurope", "westeurope"]))) == 4
    error_message = "Should contain all regions when filter is null"
  }
}

# Test deprecated availability_zones_filter for backward compatibility
run "deprecated_availability_zones_filter_true" {
  command = apply

  variables {
    availability_zones_filter = true
    has_availability_zones    = null # Should not interfere
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Deprecated filter should still work: return regions with zones"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.zones != null && length(r.zones) > 0])
    error_message = "All returned regions should have availability zones (deprecated filter)"
  }
}

run "deprecated_availability_zones_filter_false" {
  command = apply

  variables {
    availability_zones_filter = false
    has_availability_zones    = null # Should not interfere
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Deprecated filter false should return all regions"
  }
}
