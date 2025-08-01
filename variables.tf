variable "availability_zones_filter" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
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

variable "recommended_filter" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
If true, the module will only return regions that are have the category set to `Recommended` by the locations API.
This is default `true` as several regions are not available for general deployment and must be explicitly made available via support ticket.
Enabling these regions by default may lead to deployment failures.
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
