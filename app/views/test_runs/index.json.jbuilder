json.array!(@test_runs) do |test_run|
  json.extract! test_run, :state
  json.url test_run_url(test_run, format: :json)
end
