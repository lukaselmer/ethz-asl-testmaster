json.array!(@test_machine_configs) do |test_machine_config|
  json.extract! test_machine_config, :name, :command_line_arguments, :test_run_id
  json.url test_machine_config_url(test_machine_config, format: :json)
end
