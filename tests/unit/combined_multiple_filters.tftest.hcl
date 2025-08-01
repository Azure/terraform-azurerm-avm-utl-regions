mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test combining multiple filters: geography, recommended, and region filters
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
          displayName = "Central US EUAP",
          id          = "/subscriptions/test/locations/centraluseuap",
          metadata = {
            geography      = "United States",
            geographyGroup = "US",
            latitude       = "41.5908",
            longitude      = "-93.6208",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/eastus2euap",
                name = "eastus2euap"
              }
            ],
            physicalLocation = "Iowa",
            regionCategory   = "Other",
            regionType       = "Physical"
          },
          name                = "centraluseuap",
          regionalDisplayName = "(US) Central US EUAP",
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
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "geography_recommended_region_all_match" {
  command = apply

  variables {
    geography_filter = "United States"
    is_recommended   = true
    region_filter    = ["eastus", "westus"]
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 regions matching all filters"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography == "United States"])
    error_message = "All regions should be from United States"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.recommended == true])
    error_message = "All regions should be recommended"
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

run "geography_recommended_region_partial_match" {
  command = apply

  variables {
    geography_filter = "United States"
    is_recommended   = true
    region_filter    = ["eastus", "northeurope"] # northeurope not in US
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 region (eastus) that matches all filters"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (US + recommended + in region filter)"
  }

  assert {
    condition     = output.regions[0].geography == "United States"
    error_message = "Should be from United States"
  }

  assert {
    condition     = output.regions[0].recommended == true
    error_message = "Should be recommended"
  }
}

run "geography_recommended_region_no_match" {
  command = apply

  variables {
    geography_filter = "United States"
    is_recommended   = false                # Only non-recommended
    region_filter    = ["eastus", "westus"] # But these are recommended
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions when filters conflict"
  }
}

run "geography_not_recommended_with_region" {
  command = apply

  variables {
    geography_filter   = "United States"
    is_recommended     = false
    recommended_filter = false # needed to avoid filtering out non-recommended regions
    region_filter      = ["centraluseuap"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 non-recommended US region"
  }

  assert {
    condition     = output.regions[0].name == "centraluseuap"
    error_message = "Should return centraluseuap (US + not recommended + in filter)"
  }

  assert {
    condition     = output.regions[0].geography == "United States"
    error_message = "Should be from United States"
  }

  assert {
    condition     = output.regions[0].recommended == false
    error_message = "Should not be recommended"
  }
}

run "all_filters_null_except_region" {
  command = apply

  variables {
    geography_filter = null
    is_recommended   = null
    region_filter    = ["eastus", "northeurope"]
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 regions based only on region filter"
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

run "complex_intersection_with_display_names" {
  command = apply

  variables {
    geography_filter = "United States"
    is_recommended   = true
    region_filter    = ["East US", "West US", "North Europe"] # Mix of display names
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 US recommended regions matched by display names"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography == "United States" && r.recommended == true])
    error_message = "All regions should be US and recommended"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus (matched by 'East US' display name)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus (matched by 'West US' display name)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should not contain northeurope (not US geography)"
  }
}
