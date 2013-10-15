class DeploymentService::CmdExecutor
  def initialize
    @log = []
  end

  def exec!(command)
    command_in = [Time.now, "> #{command}"]
    ret = %x{#{command}}
    command_out = [Time.now, ret]
    @log << [command_in, command_out]
    ret
  end

  def to_s
    @log.map do |(time_in, val_in), (time_out, val_out)|
      ["Started: #{time_in}", "Duration: #{time_out - time_in}", val_in, val_out].join("\n")
    end.join("\n--\n")
  end
end
