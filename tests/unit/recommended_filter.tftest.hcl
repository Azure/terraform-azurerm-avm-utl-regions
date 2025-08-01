mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test recommended filter (tri-state: true/false/null)
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
          displayName = "East US 2 EUAP",
          id          = "/subscriptions/test/locations/eastus2euap",
          metadata = {
            geography      = "United States",
            geographyGroup = "US",
            latitude       = "36.6681",
            longitude      = "-78.3889",
            pairedRegion = [
              {
                id   = "/subscriptions/test/locations/centraluseuap",
                name = "centraluseuap"
              }
            ],
            physicalLocation = "Virginia",
            regionCategory   = "Other",
            regionType       = "Physical"
          },
          name                = "eastus2euap",
          regionalDisplayName = "(US) East US 2 EUAP",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data    = true
  recommended_filter = false # disable legacy filter
}

run "is_recommended_true" {
  command = apply

  variables {
    is_recommended = true
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 recommended regions"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.recommended == true])
    error_message = "All returned regions should be recommended"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should contain eastus region (recommended)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "westus")
    error_message = "Should contain westus region (recommended)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "centraluseuap")
    error_message = "Should not contain centraluseuap region (not recommended)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "eastus2euap")
    error_message = "Should not contain eastus2euap region (not recommended)"
  }
}

run "is_recommended_false" {
  command = apply

  variables {
    is_recommended = false
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return exactly 2 non-recommended regions"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.recommended == false])
    error_message = "All returned regions should not be recommended"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "centraluseuap")
    error_message = "Should contain centraluseuap region (not recommended)"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus2euap")
    error_message = "Should contain eastus2euap region (not recommended)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "eastus")
    error_message = "Should not contain eastus region (recommended)"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "westus")
    error_message = "Should not contain westus region (recommended)"
  }
}

run "is_recommended_null" {
  command = apply

  variables {
    is_recommended = null
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Should return all 4 regions when recommended filter is null"
  }

  assert {
    condition     = length(setintersection(toset([for r in output.regions : r.name]), toset(["eastus", "westus", "centraluseuap", "eastus2euap"]))) == 4
    error_message = "Should contain all regions when filter is null"
  }
}

# Test deprecated recommended_filter for backward compatibility
run "deprecated_recommended_filter_true" {
  command = apply

  variables {
    recommended_filter = true
    is_recommended     = null # Should not interfere
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Deprecated filter should still work: return recommended regions"
  }

  assert {
    condition     = alltrue([for r in output.regions : r.recommended == true])
    error_message = "All returned regions should be recommended (deprecated filter)"
  }
}

run "deprecated_recommended_filter_false" {
  command = apply

  variables {
    recommended_filter = false
    is_recommended     = null # Should not interfere
  }

  assert {
    condition     = length(output.regions) == 4
    error_message = "Deprecated filter false should return all regions"
  }
}
