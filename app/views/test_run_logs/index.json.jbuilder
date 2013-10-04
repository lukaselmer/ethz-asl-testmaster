json.array!(@test_run_logs) do |test_run_log|
  json.extract! test_run_log, :logged_at, :message_type, :message_content, :execution_in_microseconds, :test_run_id, :test_machine_config_id
  json.url test_run_log_url(test_run_log, format: :json)
end
