class DeploymentService::JarExecutor

  def initialize(cmd_executor, jar_compiler, remote_directory)
    @jar_compiler = jar_compiler
    @compiled_dependencies_path = "#{@jar_compiler.mvn_path}/target/dependency"
    @remote_directory = remote_directory
    @setup_jar_path = @jar_compiler.setup_jar_path
    @cmd_executor = cmd_executor
  end

  def dependencies
    Dir["#{@compiled_dependencies_path}/*.*"]
  end

  def execute_setup
    jars = []
    Dir["#{@compiled_dependencies_path}/*.*"].each do |file|
      dest = "#{@jar_compiler.setup_path}/#{File.basename(file)}"
      FileUtils.copy file, dest
      jars << dest
    end
    jars << @setup_jar_path

    s = 'https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/testing_logging.properties'
    logging_properties_path = "#{@jar_compiler.setup_path}/logging.properties"
    download_from_uri(logging_properties_path, s)

    db_url = AwsService.new.resolve_db_url
    common_cmd = "#{base_command(@jar_compiler.setup_path, jars)} dbscript -url \"#{db_url}\" -db \"#{ENV['MLMQ_DB_NAME']}\" -user \"#{ENV['MLMQ_DB_USER']}\" -password \"#{ENV['MLMQ_DB_PASSWORD']}\" -l \"#{logging_properties_path}\""
    @cmd_executor.exec! "#{common_cmd} -dropDatabase -createDatabase -createTables"
  end

  def base_command(dir, jars)
    main_class = 'ch.ethz.mlmq.main.Main'
    "cd \"#{dir}\" && java -cp \"#{jars.join(':')}\" #{main_class}"
  end

  def command_for_client(jars, scenario_execution, remote_system_log_dir)
    config = "#{@remote_directory}/config.properties"
    logging = "#{@remote_directory}/logging.properties"
    "#{base_command(@remote_directory, jars)} \"#{scenario_execution.scenario.name}\" -config \"#{config}\" -l \"#{logging}\" >> \"#{remote_system_log_dir}/log.log\" 2>&1 &"
  end
end
