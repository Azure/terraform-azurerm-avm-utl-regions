variables {
  enable_telemetry       = false
  geography_group_filter = "Europe"
}


run "cached" {
  command = apply

  assert {
    condition     = alltrue([for r in output.regions : r.geography_group == "Europe"])
    error_message = "All regions be from Europe geo group."
  }
}

run "live" {
  command = apply

  variables {
    use_cached_data = false
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography_group == "Europe"])
    error_message = "All regions be from Europe geo group."
  }
}
