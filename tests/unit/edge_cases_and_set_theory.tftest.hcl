mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# Test edge cases and set theory edge conditions
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
          displayName = "Test Region With Nulls",
          id          = "/subscriptions/test/locations/testnulls",
          metadata = {
            geography        = null,
            geographyGroup   = null,
            latitude         = "0.0",
            longitude        = "0.0",
            pairedRegion     = null,
            physicalLocation = "Test Location",
            regionCategory   = "Other",
            regionType       = "Physical"
          },
          name                = "testnulls",
          regionalDisplayName = "(Test) Test Region With Nulls",
          type                = "Region"
        }
      ]
    }
  }
}

variables {
  use_cached_data = true
}

run "empty_set_intersection" {
  command = apply

  variables {
    geography_filter = "NonexistentGeography"
    region_filter    = ["eastus"] # eastus exists but not in nonexistent geography
  }

  assert {
    condition     = length(output.regions) == 0
    error_message = "Should return empty set when no regions match intersection"
  }

  assert {
    condition     = length(output.valid_region_names) == 0
    error_message = "valid_region_names should be empty"
  }

  assert {
    condition     = length(output.regions_by_name) == 0
    error_message = "regions_by_name should be empty"
  }

  assert {
    condition     = length(local.regions_by_geography) == 0
    error_message = "regions_by_geography should be empty"
  }
}

run "null_geography_and_geography_group_handling" {
  command = apply

  variables {
    geography_filter       = null
    geography_group_filter = null
    recommended_filter     = false # disable legacy filter
  }

  assert {
    condition     = length(output.regions) == 2
    error_message = "Should return all regions including those with null geography/geography_group"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "testnulls")
    error_message = "Should include region with null geography and geography_group"
  }

  assert {
    condition     = contains([for r in output.regions : r.name], "eastus")
    error_message = "Should include region with valid geography and geography_group"
  }
}

run "filter_null_geography_explicitly" {
  command = apply

  variables {
    geography_filter = "United States"
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return only regions with matching geography"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (has geography 'United States')"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "testnulls")
    error_message = "Should not include region with null geography when filtering by specific geography"
  }
}

run "filter_null_geography_group_explicitly" {
  command = apply

  variables {
    geography_group_filter = "US"
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should return only regions with matching geography group"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus (has geography_group 'US')"
  }

  assert {
    condition     = !contains([for r in output.regions : r.name], "testnulls")
    error_message = "Should not include region with null geography_group when filtering by specific geography_group"
  }
}

run "region_filter_case_sensitivity" {
  command = apply

  variables {
    region_filter = ["EASTUS", "East US"] # Test case sensitivity and display name
  }

  # Assuming the filter is case-sensitive and exact match
  assert {
    condition     = length(output.regions) == 1
    error_message = "Should match display name 'East US' but not 'EASTUS'"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus matched by display name 'East US'"
  }
}

run "region_filter_exact_name_match" {
  command = apply

  variables {
    region_filter = ["eastus"]
  }

  assert {
    condition     = length(output.regions) == 1
    error_message = "Should match exact region name"
  }

  assert {
    condition     = output.regions[0].name == "eastus"
    error_message = "Should return eastus"
  }
}

run "set_theory_validation_all_sets_defined" {
  command = apply

  variables {
    geography_filter       = "United States"
    geography_group_filter = "US"
    has_availability_zones = true
    has_pair               = true
    is_recommended         = true
    region_filter          = ["eastus"]
  }

  # Validate that all the intermediate sets are properly created
  assert {
    condition     = contains(local.locations_all_names, "eastus")
    error_message = "locations_all_names should contain all region names"
  }

  assert {
    condition     = contains(local.locations_geography_filter, "eastus")
    error_message = "locations_geography_filter should contain eastus for US geography"
  }

  assert {
    condition     = contains(local.locations_geography_group_filter, "eastus")
    error_message = "locations_geography_group_filter should contain eastus for US geography group"
  }

  assert {
    condition     = contains(local.locations_final_availability_zones_filter, "eastus")
    error_message = "locations_final_availability_zones_filter should contain eastus (has zones)"
  }

  assert {
    condition     = contains(local.locations_final_paired_region_filter, "eastus")
    error_message = "locations_final_paired_region_filter should contain eastus (has pair)"
  }

  assert {
    condition     = contains(local.locations_final_is_recommended_filter, "eastus")
    error_message = "locations_final_is_recommended_filter should contain eastus (is recommended)"
  }

  assert {
    condition     = contains(local.locations_region_filter, "eastus")
    error_message = "locations_region_filter should contain eastus (in region filter)"
  }

  assert {
    condition     = contains(local.locations_filtered_names, "eastus")
    error_message = "locations_filtered_names should contain eastus (intersection result)"
  }
}

run "validate_output_sorting" {
  command = apply

  variables {
    # No filters to get all regions
  }

  assert {
    condition     = output.valid_region_display_names == sort(output.valid_region_display_names)
    error_message = "valid_region_names should be sorted"
  }

  assert {
    condition     = output.valid_region_display_names == sort(output.valid_region_display_names)
    error_message = "valid_region_display_names should be sorted"
  }
}
