variables {
  enable_telemetry = false
  zones_filter     = true
}


run "cached" {
  command = apply

  assert {
    condition     = alltrue([for r in output.regions : r.zones != null])
    error_message = "All regions should have zones."
  }
}

run "live" {
  command = apply

  variables {
    use_cached_data = false
  }

  assert {
    condition     = alltrue([for r in output.regions : r.zones != null])
    error_message = "All regions should have zones."
  }
}
