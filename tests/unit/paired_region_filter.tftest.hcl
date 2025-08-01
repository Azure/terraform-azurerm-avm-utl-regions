mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test paired region filter (tri-state: true/false/null)
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
        },
        {
          displayName = "UAE North",
          id          = "/subscriptions/test/locations/uaenorth",
          metadata = {
            geography        = "United Arab Emirates",
            geographyGroup   = "Middle East",
            latitude         = "25.266",
            longitude        = "55.296",
            pairedRegion     = null,
            physicalLocation = "Dubai",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "uaenorth",
          regionalDisplayName = "(Middle East) UAE North",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "has_pair_true" {
  command = apply

  variables {
    has_pair = true
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions with paired regions"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.paired_region_name != null])
    error_message = "All returned regions should have paired regions"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region (has pair)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus region (has pair)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "brazilsouth")
    error_message = "Should not contain brazilsouth region (no pair)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "uaenorth")
    error_message = "Should not contain uaenorth region (no pair)"
  }
}

run "has_pair_false" {
  command = apply

  variables {
    has_pair = false
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 regions without paired regions"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.paired_region_name == null])
    error_message = "All returned regions should not have paired regions"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "brazilsouth")
    error_message = "Should contain brazilsouth region (no pair)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "uaenorth")
    error_message = "Should contain uaenorth region (no pair)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "eastus")
    error_message = "Should not contain eastus region (has pair)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "westus")
    error_message = "Should not contain westus region (has pair)"
  }
}

run "has_pair_null" {
  command = apply

  variables {
    has_pair = null
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Should return all 4 regions when paired region filter is null"
  }

  assert {
    condition     = length(setintersection(toset([for r in output.regions : r.name]), toset(["eastus", "westus", "brazilsouth", "uaenorth"]))) == 4
    error_message = "Should contain all regions when filter is null"
  }
}

# Test that regions with paired regions have correct pair names
run "paired_region_names_correct" {
  command = apply

  variables {
    has_pair = true
  }

  assert {
    condition = alltrue([
      for r in output.regions :
      (r.name == "eastus" && r.paired_region_name == "westus") ||
      (r.name == "westus" && r.paired_region_name == "eastus")
    ])
    error_message = "Paired region names should be correctly set"
  }
}
