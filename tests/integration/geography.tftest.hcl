variables {
  enable_telemetry = false
  geography_filter = "United States"
}


run "cached" {
  command = apply

  assert {
    condition     = alltrue([for r in output.regions : r.geography == "United States"])
    error_message = "All regions be from United States geo."
  }
}

run "live" {
  command = apply

  variables {
    use_cached_data = false
  }

  assert {
    condition     = alltrue([for r in output.regions : r.geography == "United States"])
    error_message = "All regions be from United States geo."
  }
}
