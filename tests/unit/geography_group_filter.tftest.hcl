mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test geography group filter with mocked data
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
  geography_group_filter = "US"
  use_cached_data        = true
}

run "geography_group_filter_us" {
  command = apply

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions for US geography group"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography_group == "US"])
    error_message = "All returned regions should have geography_group 'US'"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus region"
  }

  assert {
    condition     = length(local.regions_by_geography_group) == 1
    error_message = "regions_by_geography_group should have exactly 1 entry"
  }

  assert {
    condition     = contains(keys(local.regions_by_geography_group), "US")
    error_message = "regions_by_geography_group should contain 'US' key"
  }
}

run "geography_group_filter_europe" {
  command = apply

  variables {
    geography_group_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions for Europe geography group"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography_group == "Europe"])
    error_message = "All returned regions should have geography_group 'Europe'"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should contain northeurope region"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westeurope")
    error_message = "Should contain westeurope region"
  }
}

run "geography_group_filter_nonexistent" {
  command = apply

  variables {
    geography_group_filter = "NonexistentGroup"
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions for nonexistent geography group"
  }

  assert {
    condition     = length(local.regions_by_geography_group) == 0
    error_message = "regions_by_geography_group should be empty for nonexistent geography group"
  }
}

run "no_geography_group_filter" {
  command = apply

  variables {
    geography_group_filter = null
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Should return all 4 regions when no geography group filter is applied"
  }

  assert {
    condition     = length(local.regions_by_geography_group) == 2
    error_message = "regions_by_geography_group should have 2 entries when no filter is applied"
  }
}
