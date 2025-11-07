variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "geo_code_fallback_to_calculated_enabled" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
If true, the module will fallback to using a calculated geo code if a geo code is not found in the predefined list.
If false, the module will only use predefined geo codes and will set the geo code to null if not found.

This can be useful if the geo code is use in naming conventions only, but should may not work for private endpoint usage.

DESCRIPTION
}

variable "geography_filter" {
  type        = string
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions that match the specified geography.
DESCRIPTION
}

variable "geography_group_filter" {
  type        = string
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions that match the specified geography group.
DESCRIPTION
}

variable "has_availability_zones" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
`null` means no filter is applied, `true` means only regions with availability zones are returned, and `false` means only regions without availability zones are returned.
DESCRIPTION
}

variable "has_pair" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
`null` means no filter is applied, `true` means only regions with a paired region are returned, and `false` means only regions without a paired region are returned.
DESCRIPTION
}

variable "is_recommended" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
`null` means no filter is applied, `true` means only regions that are recommended are returned, and `false` means only regions that are not recommended are returned.

NOTE: Set the legacy `recommended_filter` variable to `false` to ensure this works as expected.
DESCRIPTION
}

variable "region_filter" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
A set of region names (or display names) to filter the output by. If `null`, no filter is applied.
DESCRIPTION
}

variable "use_cached_data" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
If true, the module will use cached data from the data directory. If false, the module will use live data from the Azure API.

The default is true to avoid unnecessary API calls and provide a guaranteed consistent output.
Set to false to ensure the latest data is used.

Using data from the Azure APIs means that if the API response changes, then the module output will change.
This may affect deployed resources that rely on this data.
DESCRIPTION
}
