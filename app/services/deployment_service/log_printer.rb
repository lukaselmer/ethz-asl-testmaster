module DeploymentService::LogPrinter
  def log_command(command_in, command_out, logger = Rails.logger)
    time_in, val_in = command_in
    time_out, val_out = command_out
    logger.info('-- command log start')
    ["Started: #{time_in}", "Duration: #{time_out - time_in}", "> #{val_in}", val_out.to_s.strip].each do |line|
      logger.info line
    end
    logger.info('--')
  end
end
