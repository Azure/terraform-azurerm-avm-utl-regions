<!-- BEGIN_TF_DOCS -->
# By geography and with zones example

This example shows a more advanced scenario where you want to randomly pick two regions in a certain geography, with availability zones.

```hcl
terraform {
  required_version = "~> 1.6"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}


module "regions" {
  source                    = "../../"
  enable_telemetry          = var.enable_telemetry
  availability_zones_filter = true
  geography_filter          = "United States"
}


resource "random_shuffle" "two_us_region_names_with_zones" {
  input        = module.regions.valid_region_names
  result_count = 2
}

output "two_us_regions_with_zones" {
  value       = [for v in module.regions.regions : v if contains(random_shuffle.two_us_region_names_with_zones.result, v.name)]
  description = "Outputs two random US regions with zones."
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.6)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [random_shuffle.two_us_region_names_with_zones](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_two_us_regions_with_zones"></a> [two\_us\_regions\_with\_zones](#output\_two\_us\_regions\_with\_zones)

Description: Outputs two random US regions with zones.

## Modules

The following Modules are called:

### <a name="module_regions"></a> [regions](#module\_regions)

Source: ../../

Version:

<!-- END_TF_DOCS -->