<#
.SYNOPSIS
  Extracts GeoCodes from Azure Backup GeoCode Mappings JSON and updates the Terraform locals.geo.codes.tf.json file directly. It also sorts the GeoCodes alphabetically by ShortName.

  MSFT FTEs should see https://dev.azure.com/CSUSolEng/Azure%20Landing%20Zones/_wiki/wikis/ALZ-Wiki/735/Getting-Geo-Codes-For-Private-DNS-Zones for information on getting the Azure Backup GeoCode Mappings JSON file.

.EXAMPLE
  .\Convert-GeoCodesFromJsonToTfInput.ps1 -pathToAzureBackupGeoCodeMappingsJson "<YOUR PATH>\AzureBackupGeoCodeMappings.json"

  This will automatically update the locals.geo.codes.tf.json file with the new geo codes.
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]
  $pathToAzureBackupGeoCodeMappingsJson
)

# Get the script directory and construct path to locals.geo.codes.tf.json
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$localsGeoCodesPath = Join-Path (Split-Path -Parent $scriptDir) "locals.geo.codes.tf.json"

# Read and convert the geo codes JSON
$geoCodesJson = Get-Content $pathToAzureBackupGeoCodeMappingsJson -Raw
$geoCodesJsonConverted = $geoCodesJson | ConvertFrom-Json -Depth 99

# Create a hashtable for the geo codes
$geoCodesHashtable = [ordered]@{}
$geoCodesJsonConverted | Sort-Object ShortName | ForEach-Object {
  $geoCodesHashtable[$_.ShortName] = $_.GeoCode
}

# Create the complete structure
$tfJsonStructure = @{
  locals = @{
    geo_codes_by_name = $geoCodesHashtable
  }
}

# Convert to JSON with proper formatting
$jsonOutput = $tfJsonStructure | ConvertTo-Json -Depth 10

# Write to the file
$jsonOutput | Set-Content -Path $localsGeoCodesPath -Encoding UTF8

Write-Host "Successfully updated $localsGeoCodesPath" -ForegroundColor Green
