mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test combining geography and geography group filters
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
          availabilityZoneMappings = [],
          displayName              = "West US",
          id                       = "/subscriptions/test/locations/westus",
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
          displayName = "UK South",
          id          = "/subscriptions/test/locations/uksouth",
          metadata = {
            geography      = "United Kingdom",
            geographyGroup = "Europe",
            latitude       = "50.941",
            longitude      = "-0.799",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/ukwest",
                name = "ukwest"
              }
            ],
            physicalLocation = "London",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "uksouth",
          regionalDisplayName = "(Europe) UK South",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "geography_and_geography_group_both_match" {
  command = apply

  variables {
    geography_filter       = "Europe"
    geography_group_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region matching both geography and geography group"
  }

  assert {
    condition     = output.regions[0].name == "northeurope"
    error_message = "Should return northeurope (matches both Europe geography and Europe geography group)"
  }

  assert {
    condition     = output.regions[0].geography == "Europe"
    error_message = "Returned region should have geography 'Europe'"
  }

  assert {
    condition     = output.regions[0].geography_group == "Europe"
    error_message = "Returned region should have geography_group 'Europe'"
  }
}

run "geography_and_geography_group_no_intersection" {
  command = apply

  variables {
    geography_filter       = "United States"
    geography_group_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions when geography and geography group don't have intersection"
  }
}

run "geography_filter_with_multiple_geography_groups" {
  command = apply

  variables {
    geography_filter       = null
    geography_group_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 regions for Europe geography group"
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
    condition     = contains([for r in output.regions : r.name], "uksouth")
    error_message = "Should contain uksouth region"
  }
}

run "geography_filter_different_from_geography_group" {
  command = apply

  variables {
    geography_filter       = "United Kingdom"
    geography_group_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region matching both filters"
  }

  assert {
    condition     = output.regions[0].name == "uksouth"
    error_message = "Should return uksouth (geography=UK, geography_group=Europe)"
  }

  assert {
    condition     = output.regions[0].geography == "United Kingdom"
    error_message = "Should have geography 'United Kingdom'"
  }

  assert {
    condition     = output.regions[0].geography_group == "Europe"
    error_message = "Should have geography_group 'Europe'"
  }
}
