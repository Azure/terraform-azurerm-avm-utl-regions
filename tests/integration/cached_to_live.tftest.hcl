variables {
  enable_telemetry = false
}


run "cached" {
  command = apply
}

run "live" {
  command = apply
  variables {
    use_cached_data = false
  }
}

run "cached_all" {
  command = apply
  variables {
    recommended_filter = false
  }
}

run "live_all" {
  command = apply
  variables {
    use_cached_data    = false
    recommended_filter = false
  }
}
