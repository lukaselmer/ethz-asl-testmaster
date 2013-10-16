class TestRunStopper::LogCollector
  def initialize(test_run, scenario_execution)
    @test_run = test_run
    @scenario_execution = scenario_execution
    @remote_path_config = DeploymentService::RemotePathConfig.new(test_run)
    @ssh_user = ENV['AWS_SSH_USER']
  end

  def collect_logs
    DeploymentService::EnhancedSSH.start(@scenario_execution.machine.ip_address, @ssh_user) do |ssh|
      begin
        log_dir = @remote_path_config.remote_performance_log_dir
        ssh.check_existence(log_dir)

      ensure
        puts ssh
      end
    end
  end
end
