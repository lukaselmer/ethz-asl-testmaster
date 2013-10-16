class DeploymentService::RemotePathConfig
  def initialize(test_run)
    @test_run = test_run
  end

  def remote_test_directory
    '/home/ubuntu/messaging_system/tests'
  end

  def remote_directory
    "#{remote_test_directory}/#{@test_run.id}"
  end

  def remote_run_jar_path
    "#{remote_directory}/run.jar"
  end

  def remote_performance_log_dir
    "#{remote_directory}/performance_log"
  end

  def remote_system_log_dir
    "#{remote_directory}/system_log"
  end
end
