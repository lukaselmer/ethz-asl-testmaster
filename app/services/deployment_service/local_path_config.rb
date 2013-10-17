class DeploymentService::LocalPathConfig
  def initialize(test_run)
    @test_run = test_run
  end

  def local_tmp_dir
    "#{Rails.root}/tmp/setup/#{@test_run.id}"
  end

  def run_path
    "#{local_tmp_dir}/run"
  end

  def jar_path
    "#{run_path}/run.jar"
  end

  def setup_path
    "#{run_path}/setup"
  end

  def machines_path
    "#{run_path}/machines"
  end

  def scenario_execution_folder(scenario_execution)
    "#{machines_path}/#{scenario_execution.config_folder}"
  end

  def collected_logs_path
    "#{machines_path}/collected_logs"
  end

  def scenario_execution_logs_path(scenario_execution)
    "#{collected_logs_path}/#{scenario_execution.config_folder}"
  end
end
