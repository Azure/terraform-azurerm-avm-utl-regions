mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test all filters combined to verify comprehensive set intersection logic
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
              physicalZone = "westeurope-az1"
            },
            {
              logicalZone  = "2",
              physicalZone = "westeurope-az2"
            }
          ],
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
          displayName = "Brazil South",
          id          = "/subscriptions/test/locations/brazilsouth",
          metadata = {
            geography        = "Brazil",
            geographyGroup   = "South America",
            latitude         = "-23.55",
            longitude        = "-46.633",
            pairedRegion     = null,
            physicalLocation = "Sao Paulo State",
            regionCategory   = "Other",
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

run "all_filters_comprehensive_match" {
  command = apply

  variables {
    geography_filter       = "United States"
    geography_group_filter = "US"
    has_availability_zones = true
    has_pair               = true
    is_recommended         = true
    region_filter          = ["eastus", "westus", "westeurope"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return exactly 1 region matching all strict filters"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (only US region with zones, pair, recommended, and in filter)"
  }

  assert {
    condition     = output.regions[0].geography == "United States"
    error_message = "Should have geography 'United States'"
  }

  assert {
    condition     = output.regions[0].geography_group == "US"
    error_message = "Should have geography_group 'US'"
  }

  assert {
    condition     = output.regions[0].zones != null && length(output.regions[0].zones) > 0
    error_message = "Should have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name != null
    error_message = "Should have a paired region"
  }

  assert {
    condition     = output.regions[0].recommended == true
    error_message = "Should be recommended"
  }
}

run "all_filters_no_match" {
  command = apply

  variables {
    geography_filter       = "Europe"
    geography_group_filter = "US" # Conflicting with geography
    has_availability_zones = true
    has_pair               = true
    is_recommended         = true
    region_filter          = ["eastus"]
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return no regions when filters are conflicting"
  }
}

run "all_filters_relaxed_match" {
  command = apply

  variables {
    geography_filter       = null
    geography_group_filter = "Europe"
    has_availability_zones = true
    has_pair               = true
    is_recommended         = true
    region_filter          = null
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return 1 European region with zones, pair, and recommended"
  }

  assert {
    condition     = output.regions[0].name == "westeurope"
    error_message = "Should return westeurope (Europe + zones + pair + recommended)"
  }

  assert {
    condition     = output.regions[0].geography_group == "Europe"
    error_message = "Should have geography_group 'Europe'"
  }

  assert {
    condition     = output.regions[0].zones != null && length(output.regions[0].zones) > 0
    error_message = "Should have availability zones"
  }

  assert {
    condition     = output.regions[0].paired_region_name != null
    error_message = "Should have a paired region"
  }

  assert {
    condition     = output.regions[0].recommended == true
    error_message = "Should be recommended"
  }
}

run "deprecated_filters_with_new_filters" {
  command = apply

  variables {
    # Deprecated filters
    availability_zones_filter = true
    recommended_filter        = true
    # New filters
    geography_filter       = "United States"
    has_availability_zones = null # Should not interfere with deprecated filter
    is_recommended         = null # Should not interfere with deprecated filter
    region_filter          = ["eastus", "westus"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should work with mix of deprecated and new filters"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (US + zones via deprecated filter + recommended via deprecated filter)"
  }

  assert {
    condition     = output.regions[0].geography == "United States"
    error_message = "Should have geography 'United States'"
  }

  assert {
    condition     = output.regions[0].zones != null && length(output.regions[0].zones) > 0
    error_message = "Should have availability zones (deprecated filter)"
  }

  assert {
    condition     = output.regions[0].recommended == true
    error_message = "Should be recommended (deprecated filter)"
  }
}

run "all_filters_null_should_return_all" {
  command = apply

  variables {
    geography_filter       = null
    geography_group_filter = null
    has_availability_zones = null
    has_pair               = null
    is_recommended         = null
    region_filter          = null
    # Deprecated filters should use defaults that don't restrict
    availability_zones_filter = false # Default - doesn't restrict when false
    recommended_filter        = false # Set to false so it doesn't restrict
  }

  assert {
    condition     = length(output.regions) == 5
    error_message = "Should return all regions when all filters are null/default"
  }
}

# Test that outputs are correctly filtered
run "filtered_outputs_consistency" {
  command = apply

  variables {
    geography_group_filter = "Europe"
    is_recommended         = true
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return 2 European recommended regions"
  }

  assert {
    condition     = length(output.valid_region_names) == 2
    error_message = "valid_region_names should match number of filtered regions"
  }

  assert {
    condition     = length(output.regions_by_name) == 2
    error_message = "regions_by_name should match number of filtered regions"
  }

  assert {
    condition     = length(local.regions_by_geography_group) == 1
    error_message = "regions_by_geography_group should have 1 entry (Europe)"
  }

  assert {
    condition     = length(local.regions_by_geography_group["Europe"]) == 2
    error_message = "Europe geography group should contain 2 regions"
  }
}
