class LogAnalyzerService

  def initialize
    @cmd_executor = DeploymentService::CmdExecutor.new
    @local_tmp_dir = "#{Rails.root}/tmp/analyzer"
    @run_jar = "#{@local_tmp_dir}/run.jar"
    setup_path = "#{@local_tmp_dir}"
    @git_cloner = DeploymentService::GitCloner.new(@cmd_executor, @local_tmp_dir)
    @jar_compiler = DeploymentService::JarCompiler.new(@cmd_executor, @git_cloner.git_path, @run_jar, setup_path, 'log_analyzer')
    @jar_executor = DeploymentService::JarExecutor.new(@cmd_executor, @jar_compiler, @remote_directory)
  end

  def build
    @cmd_executor.exec!("rm -rf #{@local_tmp_dir}")
    @git_cloner.clone_git
    @jar_compiler.compile_jar

  end

  def analyze(test_run, output_format, window_size, other)
    build unless File.exist? @run_jar

    c = DeploymentService::LocalPathConfig.new(test_run)
    ext = analyzer_ext(output_format, :raw)
    outfile = c.analyzer_out_file(test_run, output_format, window_size, other, :raw)

    unless File.exist? outfile
      @cmd_executor.exec!("mkdir #{c.analyzer_out_path}")
      @cmd_executor.exec!("rm #{outfile}")

      other_str = other.collect { |k, v| v.blank? ? '' : " -#{k} '#{v}'" }.join('')
      params = "-directory_to_log_files #{c.collected_logs_path} -output_format '#{ext}' -window_size '#{window_size}'#{other_str} > #{outfile}"
      @jar_executor.execute_log_analyzer params
    end

    if %w(png eps).include? output_format
      img_outfile = c.analyzer_out_file(test_run, output_format, window_size, other, :out)
      @cmd_executor.exec!("gnuplot #{outfile} > #{img_outfile}") unless File.exist? img_outfile
      outfile = img_outfile
    end

    outfile
  end

end
