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

  def scenario_execution_folder(scenario_execution, sej)
    "#{machines_path}/#{scenario_execution.config_folder}/#{sej.id}"
  end

  def collected_logs_path
    "#{machines_path}/collected_logs"
  end

  def scenario_execution_logs_path(scenario_execution)
    "#{collected_logs_path}/#{scenario_execution.config_folder}"
  end

  def zip_status_file
    "#{run_path}/zipping.txt"
  end

  def zip_file
    "#{run_path}/logs.zip"
  end

  def analyzer_out_path
    "#{run_path}/analized_logs"
  end

  def analyzer_out_file(test_run, ext='out')
    "#{analyzer_out_path}/#{test_run.id}_#{Time.now.strftime('%Y%m%d_%H%M%S_%L')}_#{ext ? ".#{ext}" : ''}"
  end
end
