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

variable "geography_filters" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions that match any of the specified geographies.
DESCRIPTION
}

variable "geography_group_filter" {
  type        = string
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions that match the specified geography group.
DESCRIPTION
}

variable "geography_group_filters" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions that match any of the specified geography groups.
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
DESCRIPTION
}

variable "region_filter" {
  type        = set(string)
  default     = null
  description = <<DESCRIPTION
An inclusive set of region names (or display names) to filter the output by. If `null`, no filter is applied.
DESCRIPTION
}

variable "region_name_regex" {
  type        = string
  default     = null
  description = <<DESCRIPTION
If set, the module will only return regions where the region name matches the specified regular expression.
The default match mode is `match`, which means the region name must match the regex.
You can change this behavior to `not_match` by setting the `region_name_regex_mode` variable.
DESCRIPTION
}

variable "region_name_regex_mode" {
  type        = string
  default     = "match"
  description = <<DESCRIPTION
Specifies the regex mode to use when filtering by `region_name_regex`.

- `match`: The region name must match the regex.
- `not_match`: The region name must not match the regex.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["match", "not_match"], var.region_name_regex_mode)
    error_message = "region_name_regex_mode must be either 'match' or 'not_match'."
  }
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
