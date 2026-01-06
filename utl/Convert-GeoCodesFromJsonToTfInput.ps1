<#
.SYNOPSIS
  Extracts GeoCodes from Azure Backup GeoCode Mappings JSON and formats into correct input for Terraform locals.geo.codes.tf.json and copies them to clipboard ready for you to paste and replace contents of that file. It also sorts the GeoCodes alphabetically by ShortName.

  MSFT FTEs should see https://dev.azure.com/CSUSolEng/Azure%20Landing%20Zones/_wiki/wikis/ALZ-Wiki/735/Getting-Geo-Codes-For-Private-DNS-Zones for information on getting the Azure Backup GeoCode Mappings JSON file.

.EXAMPLE
  .\Convert-GeoCodesFromJsonToTfInput.ps1 -pathToAzureBackupGeoCodeMappingsJson "<YOUR PATH>\AzureBackupGeoCodeMappings.json"

  Then paste the clipboard contents into `locals.geo.codes.tf.json` and replace the contents of the `geo_codes_by_name` object.
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]
  $pathToAzureBackupGeoCodeMappingsJson
)

$geoCodesJson = Get-Content $pathToAzureBackupGeoCodeMappingsJson -Raw
$geoCodesJsonConverted = $geoCodesJson | ConvertFrom-Json -Depth 99

$output = $geoCodesJsonConverted | ForEach-Object {
  "`"$($_.ShortName)`": `"$($_.GeoCode)`","
}

$output | Sort-Object | Set-Clipboard
