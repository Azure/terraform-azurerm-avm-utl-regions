mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test geography filter with mocked data
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
          displayName = "East Asia",
          id          = "/subscriptions/test/locations/eastasia",
          metadata = {
            geography      = "Asia Pacific",
            geographyGroup = "Asia Pacific",
            latitude       = "22.267",
            longitude      = "114.188",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/southeastasia",
                name = "southeastasia"
              }
            ],
            physicalLocation = "Hong Kong",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "eastasia",
          regionalDisplayName = "(Asia Pacific) East Asia",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  geography_filter = "United States"
  use_cached_data  = true
}

run "geography_filter_united_states" {
  command = apply

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return exactly 1 region for United States geography"
  }

  assert {
    condition     = output.regions[0].geography == "United States"
    error_message = "Returned region should have geography 'United States'"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Returned region should be 'eastus'"
  }

  assert {
    condition     = length(local.regions_by_geography) == 1
    error_message = "regions_by_geography should have exactly 1 entry"
  }

  assert {
    condition     = contains(keys(local.regions_by_geography), "United States")
    error_message = "regions_by_geography should contain 'United States' key"
  }
}

run "geography_filter_europe" {
  command = apply

  variables {
    geography_filter = "Europe"
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return exactly 1 region for Europe geography"
  }

  assert {
    condition     = output.regions[0].geography == "Europe"
    error_message = "Returned region should have geography 'Europe'"
  }

  assert {
    condition     = output.regions[0].name == "northeurope"
    error_message = "Returned region should be 'northeurope'"
  }
}

run "geography_filter_nonexistent" {
  command = apply

  variables {
    geography_filter = "NonexistentGeography"
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions for nonexistent geography"
  }

  assert {
    condition     = length(local.regions_by_geography) == 0
    error_message = "regions_by_geography should be empty for nonexistent geography"
  }
}

run "no_geography_filter" {
  command = apply

  variables {
    geography_filter = null
  }

  assert {
    condition     = length(output.regions) == 3
    error_message = "Should return all 3 regions when no geography filter is applied"
  }

  assert {
    condition     = length(local.regions_by_geography) == 3
    error_message = "regions_by_geography should have 3 entries when no filter is applied"
  }
}
