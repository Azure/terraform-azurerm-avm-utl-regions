output "locations_cached" {
  description = "The cached list of locations from the API. Output is a list of location objects under the `value` key."
  value       = local.locations_cached
}
