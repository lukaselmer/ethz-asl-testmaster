class DeploymentService::CmdExecutor
  include DeploymentService::LogPrinter

  def initialize
    @log = []
  end

  def exec!(command)
    command_in = [Time.now, "> #{command}"]
    ret = %x{#{command}}
    command_out = [Time.now, ret]
    log_command(command_in, command_out)
    ret
  end
end
