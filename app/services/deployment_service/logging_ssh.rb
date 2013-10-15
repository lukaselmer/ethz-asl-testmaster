class DeploymentService::LoggingSSH
  def initialize(ssh)
    @ssh = ssh
    @log = []
  end

  def exec!(command)
    method_call_with_logging(:exec!, command)
  end

  def exec(command)
    method_call_with_logging(:exec, command)
  end

  def method_call_with_logging(method, command)
    command_in = [Time.now, "> #{command}"]
    ret = @ssh.send(method, command)
    command_out = [Time.now, ret]
    @log << [command_in, command_out]
    ret
  end

  def to_s
    @log.map do |(time_in, val_in), (time_out, val_out)|
      ["Started: #{time_in}", "Duration: #{time_out - time_in}", val_in, val_out].join("\n")
    end.join("\n\n--\n")
  end
end
