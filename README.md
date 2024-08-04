<!-- BEGIN_TF_DOCS -->
# Azure Regions and Availability Zones module

This module provides an output of all Azure regions and availability zones.

The module outputs a list of objects with the following attributes:

- `name` - The name of the region. E.g. "eastus"
- `display_name` - The display name of the region. E.g. "East US".
- `paired_region_name` - The name of the region paired with this region.  May be `null` if the region has no pair.
- `geography` - The geography of the region.
- `geography_group` - The geography group of the region.
- `zones` - A list of the availability zones in the region. Will be `null` if the region does not support zones.

This data is the further composed into useful maps keyed by region name and region display name.
Useful filters are also provided.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.6)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.9)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.current](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) (data source)
- [azapi_resource_action.locations](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_action) (data source)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_availability_zones_filter"></a> [availability\_zones\_filter](#input\_availability\_zones\_filter)

Description: If true, the module will only return regions that have availability zones.

Type: `bool`

Default: `false`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_geography_filter"></a> [geography\_filter](#input\_geography\_filter)

Description: If set, the module will only return regions that match the specified geography.

Type: `string`

Default: `null`

### <a name="input_geography_group_filter"></a> [geography\_group\_filter](#input\_geography\_group\_filter)

Description: If set, the module will only return regions that match the specified geography group.

Type: `string`

Default: `null`

### <a name="input_recommended_filter"></a> [recommended\_filter](#input\_recommended\_filter)

Description: If true, the module will only return regions that are have the category set to `Recommended` by the locations API.  
This is default `true` as several regions are not available for general deployment and must be explicitly made available via support ticket.  
Enabling these regions by default may lead to deployment failures.

Type: `bool`

Default: `true`

### <a name="input_use_cached_data"></a> [use\_cached\_data](#input\_use\_cached\_data)

Description: If true, the module will use cached data from the data directory. If false, the module will use live data from the Azure API.

The default is true to avoid unnecessary API calls and provide a guaranteed consistent output.  
Set to false to ensure the latest data is used.

Using data from the Azure APIs means that if the API response changes, then the module output will change.  
This may affect deployed resources that rely on this data.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_regions"></a> [regions](#output\_regions)

Description: A list of region objects subject to the filters supplied by input variables. Each region object contains the following attributes:

- `name` - The name of the region.
- `display_name` - The display name of the region.
- `paired_region_name` - The name of the region paired with this region. May be `null` if the region has no pair.
- `geography` - The geography of the region.
- `geography_group` - The geography group of the region.
- `zones` - A list of the availability zones in the region. Will be empty if the region does not support zones.

### <a name="output_regions_by_display_name"></a> [regions\_by\_display\_name](#output\_regions\_by\_display\_name)

Description: A map of region display names to region objects subject to the filters supplied by input variables. See `regions` output for more details.

### <a name="output_regions_by_geography"></a> [regions\_by\_geography](#output\_regions\_by\_geography)

Description: A map of geographies to a list of region objects subject to the filters supplied by input variables. See `regions` output for more details.

### <a name="output_regions_by_geography_group"></a> [regions\_by\_geography\_group](#output\_regions\_by\_geography\_group)

Description: A map of geography groups to a list of region objects subject to the filters supplied by input variables. See `regions` output for more details.

### <a name="output_regions_by_name"></a> [regions\_by\_name](#output\_regions\_by\_name)

Description: A map of region display names to region objects subject to the filters supplied by input variables. See `regions` output for more details.

### <a name="output_regions_by_name_or_display_name"></a> [regions\_by\_name\_or\_display\_name](#output\_regions\_by\_name\_or\_display\_name)

Description: A map of regions by either display names or name, to region objects subject to the filters supplied by input variables. See `regions` output for more details.

### <a name="output_valid_region_display_names"></a> [valid\_region\_display\_names](#output\_valid\_region\_display\_names)

Description: A set of valid region display names subject to the filters supplied by input variables.

### <a name="output_valid_region_names"></a> [valid\_region\_names](#output\_valid\_region\_names)

Description: A set of valid region names subject to the filters supplied by input variables.

### <a name="output_valid_region_names_or_display_names"></a> [valid\_region\_names\_or\_display\_names](#output\_valid\_region\_names\_or\_display\_names)

Description: A set of valid region names or display names subject to the filters supplied by input variables.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->