json.array!(@machines) do |machine|
  json.extract! machine, :host, :profile, :state, :private_key, :additional_info
  json.url machine_url(machine, format: :json)
end
