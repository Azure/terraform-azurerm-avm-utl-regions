mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  enable_telemetry = false
  location         = "usgovvirginia"
  use_cached_data  = false
}

override_data {
  target = data.azapi_resource_action.locations[0]
  values = {
    output = {
      value = [
        {
          displayName = "USGov Virginia"
          name        = "usgovvirginia"
          metadata = {
            geography      = "United States"
            regionCategory = "Recommended"
            regionType     = "Physical"
          }
          availabilityZoneMappings = [
            { logicalZone = "1" },
            { logicalZone = "2" },
            { logicalZone = "3" }
          ]
        },
        {
          displayName = "USGov Arizona"
          name        = "usgovarizona"
          metadata = {
            geography      = "United States"
            regionCategory = "Recommended"
            regionType     = "Physical"
          }
          availabilityZoneMappings = [{ logicalZone = "1" }]
        },
        {
          displayName = "USGov Texas"
          name        = "usgovtexas"
          metadata = {
            geography      = "United States"
            regionCategory = "Recommended"
            regionType     = "Physical"
          }
          availabilityZoneMappings = []
        },
        {
          displayName = "USDoD Central"
          name        = "usdodcentral"
          metadata = {
            geography      = "United States"
            regionCategory = "Recommended"
            regionType     = "Physical"
          }
        }
      ]
    }
  }
}

run "live_mixed_zone_counts" {
  command = apply

  assert {
    condition     = length(output.regions) == 4
    error_message = "All synthetic live regions should survive list type unification."
  }

  assert {
    condition     = output.regions_by_name["usgovvirginia"].zones == tolist([1, 2, 3]) && output.regions_by_name["usgovarizona"].zones == tolist([1])
    error_message = "Different zone counts should normalize to numeric lists."
  }

  assert {
    condition     = alltrue([for name in ["usgovtexas", "usdodcentral"] : output.regions_by_name[name].zones != null && length(output.regions_by_name[name].zones) == 0])
    error_message = "Empty and missing zone mappings should normalize to empty lists."
  }
}

run "live_with_zones" {
  command = apply

  variables {
    has_availability_zones = true
  }

  assert {
    condition     = toset(keys(output.regions_by_name)) == toset(["usgovvirginia", "usgovarizona"])
    error_message = "Only live regions with nonempty zone lists should match."
  }
}

run "live_without_zones" {
  command = apply

  variables {
    has_availability_zones = false
  }

  assert {
    condition     = toset(keys(output.regions_by_name)) == toset(["usgovtexas", "usdodcentral"])
    error_message = "Live regions with empty or missing zone mappings should match."
  }
}

run "cached_data_without_live_lookup" {
  command = apply

  variables {
    use_cached_data = true
  }

  assert {
    condition     = local.live_locations_list != null && length(local.live_locations_list) == 0 && length(output.regions) > 0
    error_message = "Cached mode should leave the live list empty and return cached regions."
  }
}
