data "azapi_client_config" "current" {}

module "cached_data" {
  source = "./modules/cached-data"
}

data "azapi_resource_action" "locations" {
  count = var.use_cached_data ? 0 : 1

  action                 = "locations"
  method                 = "GET"
  resource_id            = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type                   = "Microsoft.Resources/subscriptions@2023-07-01"
  response_export_values = ["value"]
}
