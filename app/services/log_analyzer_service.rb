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

  def analyze(test_run, type, output_format, window_size)
    build unless File.exist? @run_jar

    c = DeploymentService::LocalPathConfig.new(test_run)
    outfile = c.analyzer_out_file(output_format)

    @cmd_executor.exec!("mkdir #{c.analyzer_out_path}")
    @cmd_executor.exec!("rm #{outfile}")

    params = "-d #{c.collected_logs_path} -type #{type} -fmt #{output_format} -w #{window_size} > #{outfile}"
    @jar_executor.execute_log_analyzer params

    if output_format.start_with? 'Gnu-'
      ext = output_format.split('-')[1]
      img_outfile = c.analyzer_out_file(ext)
      @cmd_executor.exec!("gnuplot #{outfile} > #{img_outfile}")
      outfile = img_outfile
    end

    outfile
  end

end
