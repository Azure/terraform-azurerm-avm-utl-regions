variable "availability_zones_filter" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
DEPRECATED: Use `var.has_availability_zones` instead.

If true, the module will only return regions that have availability zones.
DESCRIPTION
}

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

variable "recommended_filter" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
DEPRECATED: Use `var.is_recommended` instead.

If true, the module will only return regions that are have the category set to `Recommended` by the locations API.
This is default `true` as several regions are not available for general deployment and must be explicitly made available via support ticket.
Enabling these regions by default may lead to deployment failures.
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
