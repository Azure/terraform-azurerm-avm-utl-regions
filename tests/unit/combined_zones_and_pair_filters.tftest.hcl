mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test combining availability zones and paired region filters
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
            geography        = "Europe",
            geographyGroup   = "Europe",
            latitude         = "53.3478",
            longitude        = "-6.2597",
            pairedRegion     = null,
            physicalLocation = "Ireland",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "northeurope",
          regionalDisplayName = "(Europe) North Europe",
          type                = "Region"
        },
        {
          displayName = "Brazil South",
          id          = "/subscriptions/test/locations/brazilsouth",
          metadata = {
            geography        = "Brazil",
            geographyGroup   = "South America",
            latitude         = "-23.55",
            longitude        = "-46.633",
            pairedRegion     = null,
            physicalLocation = "Sao Paulo State",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "brazilsouth",
          regionalDisplayName = "(South America) Brazil South",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "has_zones_and_has_pair_both_true" {
  command = apply

  variables {
    has_availability_zones = true
    has_pair               = true
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region with both availability zones and paired region"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (has zones and has pair)"
  }

  assert {
    condition     = output.regions[0].zones != null && length(output.regions[0].zones) > 0
    error_message = "Returned region should have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name != null
    error_message = "Returned region should have a paired region"
  }
}

run "has_zones_true_has_pair_false" {
  command = apply

  variables {
    has_availability_zones = true
    has_pair               = false
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region with zones but no pair"
  }

  assert {
    condition     = output.regions[0].name == "northeurope"
    error_message = "Should return northeurope (has zones, no pair)"
  }

  assert {
    condition     = output.regions[0].zones != null && length(output.regions[0].zones) > 0
    error_message = "Returned region should have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name == null
    error_message = "Returned region should not have a paired region"
  }
}

run "has_zones_false_has_pair_true" {
  command = apply

  variables {
    has_availability_zones = false
    has_pair               = true
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region without zones but with pair"
  }

  assert {
    condition     = output.regions[0].name == "westus"
    error_message = "Should return westus (no zones, has pair)"
  }

  assert {
    condition     = output.regions[0].zones == null || length(output.regions[0].zones) == 0
    error_message = "Returned region should not have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name != null
    error_message = "Returned region should have a paired region"
  }
}

run "has_zones_false_has_pair_false" {
  command = apply

  variables {
    has_availability_zones = false
    has_pair               = false
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region without zones and without pair"
  }

  assert {
    condition     = output.regions[0].name == "brazilsouth"
    error_message = "Should return brazilsouth (no zones, no pair)"
  }

  assert {
    condition     = output.regions[0].zones == null || length(output.regions[0].zones) == 0
    error_message = "Returned region should not have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name == null
    error_message = "Returned region should not have a paired region"
  }
}

run "has_zones_null_has_pair_true" {
  command = apply

  variables {
    has_availability_zones = null
    has_pair               = true
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 regions with paired regions (zones filter ignored)"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.paired_region_name != null])
    error_message = "All returned regions should have paired regions"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus"
  }
}

run "has_zones_true_has_pair_null" {
  command = apply

  variables {
    has_availability_zones = true
    has_pair               = null
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 regions with availability zones (pair filter ignored)"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.zones != null && length(r.zones) > 0])
    error_message = "All returned regions should have availability zones"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should contain northeurope"
  }
}
