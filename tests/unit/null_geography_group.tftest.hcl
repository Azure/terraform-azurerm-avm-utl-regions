mock_provider "azapi" {}
mock_provider "modtm" {}
mock_provider "random" {}

# This contains regions with null for geography_group and geography
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
              physicalZone = "eastus-az3"
            },
            {
              logicalZone  = "3",
              physicalZone = "eastus-az2"
            }
          ],
          displayName = "East US",
          id          = "/subscriptions/2a8527ca-5340-49aa-8931-ea03669451a0/locations/eastus",
          metadata = {
            geography      = "United States",
            geographyGroup = null,
            latitude       = "37.3719",
            longitude      = "-79.8164",
            pairedRegion = [
              {
                id   = "/subscriptions/2a8527ca-5340-49aa-8931-ea03669451a0/locations/westus",
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
          availabilityZoneMappings = [
            {
              logicalZone  = "1",
              physicalZone = "westus-az1"
            },
            {
              logicalZone  = "2",
              physicalZone = "westus-az2"
            },
            {
              logicalZone  = "3",
              physicalZone = "westus-az3"
            }
          ],
          displayName = "West US",
          id          = "/subscriptions/2a8527ca-5340-49aa-8931-ea03669451a0/locations/westus",
          metadata = {
            geography      = null
            geographyGroup = "US",
            latitude       = "37.3719",
            longitude      = "-79.8164",
            pairedRegion = [
              {
                id   = "/subscriptions/2a8527ca-5340-49aa-8931-ea03669451a0/locations/eastus",
                name = "eastus"
              }
            ],
            physicalLocation = "Virginia",
            regionCategory   = "Recommended",
            regionType       = "Physical"
          },
          name                = "westus",
          regionalDisplayName = "(US) West US",
          type                = "Region"
        }
      ]
    }
  }
}

run "apply" {
  command = apply

  assert {
    error_message = "Regions by geography group should only have one entry"
    condition     = length(local.regions_by_geography_group) == 1
  }

  assert {
    error_message = "Regions by geography should only have one entry"
    condition     = length(local.regions_by_geography) == 1
  }
}
