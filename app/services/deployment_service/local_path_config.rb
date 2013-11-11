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

  def hash_code(window_size, other)
    require 'digest'
    Digest::SHA1.hexdigest("#{window_size.hash}_#{other.hash}")
  end

  def analyzer_ext(ext, step)
    "#{ext}.gnu" if step == :raw && %w(png eps).include?(ext)
  end

  def analyzer_out_file(test_run, ext, window_size, other, step)
    ext = analyzer_ext(ext, step)

    "#{analyzer_out_path}/#{test_run.id}_#{hash_code(window_size, other)}_#{ext ? ".#{ext}" : ''}"
  end
end
