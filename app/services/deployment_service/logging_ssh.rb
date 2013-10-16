class DeploymentService::LoggingSSH
  include DeploymentService::LogPrinter

  def initialize(ssh)
    @ssh = ssh
  end

  def exec!(command)
    method_call_with_logging(:exec!, command)
  end

  def exec(command)
    method_call_with_logging(:exec, command)
  end

  def method_call_with_logging(method, command)
    command_in = [Time.now, command]
    ret = @ssh.send(method, command)
    command_out = [Time.now, ret]
    log_command(command_in, command_out)
    ret
  end
end
