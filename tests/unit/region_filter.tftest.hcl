mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test region filter (set of region names or display names)
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
  use_cached_data = true
}

run "region_filter_by_names" {
  command = apply

  variables {
    region_filter = ["eastus", "northeurope"]
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions when filtering by names"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should contain northeurope region"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "westus")
    error_message = "Should not contain westus region"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "westeurope")
    error_message = "Should not contain westeurope region"
  }
}

run "region_filter_by_display_names" {
  command = apply

  variables {
    region_filter = ["East US", "West Europe"]
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions when filtering by display names"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region (matched by display name 'East US')"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westeurope")
    error_message = "Should contain westeurope region (matched by display name 'West Europe')"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "westus")
    error_message = "Should not contain westus region"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "northeurope")
    error_message = "Should not contain northeurope region"
  }
}

run "region_filter_mixed_names_and_display_names" {
  command = apply

  variables {
    region_filter = ["eastus", "West Europe"]
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions when filtering by mixed names and display names"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region (matched by name)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westeurope")
    error_message = "Should contain westeurope region (matched by display name)"
  }
}

run "region_filter_single_region" {
  command = apply

  variables {
    region_filter = ["westus"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return exactly 1 region when filtering by single name"
  }

  assert {
    condition     = output.regions[0].name == "westus"
    error_message = "Should return westus region"
  }
}

run "region_filter_nonexistent" {
  command = apply

  variables {
    region_filter = ["nonexistentregion", "anothernonexistent"]
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions when filtering by nonexistent names"
  }
}

run "region_filter_partial_match" {
  command = apply

  variables {
    region_filter = ["eastus", "nonexistentregion"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return only the existing region when partial match"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus region (the existing one)"
  }
}

run "region_filter_null" {
  command = apply

  variables {
    region_filter = null
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Should return all regions when filter is null"
  }
}

# Test that the valid region names outputs work correctly
run "valid_region_names_with_filter" {
  command = apply

  variables {
    region_filter = ["eastus", "northeurope"]
  }

  assert {
    condition     = length(output.valid_region_names) == 2
    error_message = "valid_region_names should match filtered regions"
  }

  assert {
    condition     = contains(output.valid_region_names, "eastus")
    error_message = "valid_region_names should contain eastus"
  }

  assert {
    condition     = contains(output.valid_region_names, "northeurope")
    error_message = "valid_region_names should contain northeurope"
  }
}
