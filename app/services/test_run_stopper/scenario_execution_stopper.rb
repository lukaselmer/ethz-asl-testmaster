class TestRunStopper::ScenarioExecutionStopper
  def initialize(test_run, scenario_execution)
    @test_run = test_run
    @scenario_execution = scenario_execution
    @remote_path_config = DeploymentService::RemotePathConfig.new(test_run)
    @ssh_user = ENV['AWS_SSH_USER']
  end

  def stop_scenario
    DeploymentService::EnhancedSSH.start(@scenario_execution.machine.ip_address, @ssh_user) do |ssh|
      begin
        ssh.exec!("echo 'shutdown' > #{@remote_path_config.remote_directory}")
      ensure
        puts ssh
      end
    end
  end
end
