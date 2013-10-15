module DeploymentService::LogPrinter
  def log_to_string(log)
    log.map do |(time_in, val_in), (time_out, val_out)|
      ["Started: #{time_in}", "Duration: #{time_out - time_in}", val_in, val_out].join("\n")
    end.join("\n--\n")
  end
end
