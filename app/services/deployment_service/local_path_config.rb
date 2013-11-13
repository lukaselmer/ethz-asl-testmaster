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
    "#{run_path}/analyzed_logs"
  end

  def hash_code(output_format, window_size, other, analyzer_version, txt_analyzer_version = 1)
    require 'digest'
    if output_format.to_sym == :txt
      key = %w(message_type startup_cooldown_time).collect{|k| other[k]}.join('_')
      return Digest::SHA1.hexdigest("#{key}_#{txt_analyzer_version}")
    end

    Digest::SHA1.hexdigest("#{window_size.hash}_#{other.hash}_#{analyzer_version}")
  end

  def analyzer_ext(ext, step)
    (step == :raw && %w(png eps).include?(ext)) ? "#{ext}.gnu" : ext
  end

  def analyzer_out_file(test_run, output_format, ext, window_size, other, step, analyzer_version)
    ext = analyzer_ext(ext, step)

    "#{analyzer_out_path}/#{test_run.id}_#{hash_code(output_format, window_size, other, analyzer_version)}.#{ext}"
  end
end
