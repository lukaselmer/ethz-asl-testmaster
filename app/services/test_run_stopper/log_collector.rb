class TestRunStopper::LogCollector
  def initialize(test_run, scenario_execution)
    @test_run = test_run
    @scenario_execution = scenario_execution
    @remote_path_config = DeploymentService::RemotePathConfig.new(test_run)
    @local_path_config = DeploymentService::LocalPathConfig.new(test_run)
    @ssh_user = ENV['AWS_SSH_USER']
  end

  def collect_logs
    dest = @local_path_config.scenario_execution_logs_path(@scenario_execution)
    download(@remote_path_config.remote_performance_log_dir, dest)
    download(@remote_path_config.remote_system_log_dir, dest)
  end

  def download(source, dest)
    Net::SCP.download!(@scenario_execution.machine.ip_address, @ssh_user, source, dest, recursive: true, ssh: {keys: [ENV['AWS_SSH_KEY_PATH']], paranoid: false})
  end
end
