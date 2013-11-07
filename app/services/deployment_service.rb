require 'net/scp'

class DeploymentService
  include DeploymentService::MachineMappingGenerator
  include DeploymentService::Downloader

  def initialize(test_run)
    @test_run = test_run
    @remote_path_config = DeploymentService::RemotePathConfig.new(test_run)
    @local_path_config = DeploymentService::LocalPathConfig.new(test_run)

    @ssh_user = ENV['AWS_SSH_USER']

    @cmd_executor = DeploymentService::CmdExecutor.new

    raise '@test_run needs to be persistent' if @test_run.id.nil?

    @remote_directory = @remote_path_config.remote_directory

    @git_cloner = DeploymentService::GitCloner.new(@cmd_executor, @local_path_config.local_tmp_dir)
    @jar_compiler = DeploymentService::JarCompiler.new(@cmd_executor, @git_cloner.git_path, @local_path_config.jar_path, @local_path_config.setup_path, 'mlmq')
    @jar_executor = DeploymentService::JarExecutor.new(@cmd_executor, @jar_compiler, @remote_directory)
  end

  def start_test
    raise "Directory #{@local_path_config.local_tmp_dir} already exists" if Dir.exist? @local_path_config.local_tmp_dir
    %i(local_tmp_dir run_path setup_path machines_path collected_logs_path).each { |d| FileUtils.mkpath @local_path_config.send(d) }

    check_no_other_tests_running!
    mark_as_started!
    check_associated_scenarios!

    m = MachineService.new
    m.start_db_instance
    m.ensure_aws_instances(@test_run.total_instances)
    m.start_aws_instances(@test_run.total_instances)

    mapping = generate_scenario_machine_mapping(@test_run)
    stop_java_on_machines(mapping)
    @git_cloner.clone_git
    @jar_compiler.compile_jar
    @jar_executor.execute_setup
    generate_machine_configs(mapping)
    copy_jars_and_configs_to_machines(mapping)
    start_machines(mapping)
  end

  # TODO: set private

  def check_no_other_tests_running!
    TestRun.all do |test_run|
      raise "Other test is running already: #{test_run.id}" if test_run.running?
    end
  end

  def mark_as_started!
    @test_run.update_attribute(:started_at, Time.now)
  end

  def check_associated_scenarios!
    @test_run.scenarios.each do |scenario|
      raise "Wrongly associated scenario: #{scenario.id}, was #{scenario.test_run.id}, should #{@test_run.id}" if scenario.test_run.id != @test_run.id
    end
  end

  def generate_machine_configs(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      scenario_execution.scenario_execution_jvms.each do |sej|
        path = @local_path_config.scenario_execution_folder(scenario_execution, sej)
        FileUtils.mkpath path
        sej.generate_config_files path, scenario_execution_mapping
      end
    end
  end

  def copy_jars_and_configs_to_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine
      copy_jars_and_configs_to_machine(machine, scenario_execution)
    end

  end

  def copy_jars_and_configs_to_machine(machine, scenario_execution)
    raise "Machine #{machine.instance_id} doesn't have an ip!" if machine.ip_address.to_s.blank?

    DeploymentService::EnhancedSSH.start(machine.ip_address, @ssh_user) do |ssh|
      ssh.check_deleted(@remote_directory)

      create_remote_folders(ssh)

      copy_jar(ssh, scenario_execution)
      copy_dependencies(ssh, scenario_execution)
      copy_configs(ssh, scenario_execution)
    end
  end

  def create_remote_folders(ssh)
    [@remote_path_config.remote_test_directory, @remote_directory, @remote_path_config.remote_performance_log_dir, @remote_path_config.remote_system_log_dir].each do |f|
      ssh.exec!("mkdir #{f}")
    end
  end

  def copy_jar(helper, scenario_execution)
    Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, @local_path_config.jar_path, @remote_path_config.remote_run_jar_path, ssh: {keys: [ENV['AWS_SSH_KEY_PATH']]})
    helper.check_existence(@remote_path_config.remote_run_jar_path)
  end

  def upload!(file, helper, scenario_execution)
    Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, file, "#{@remote_directory}", ssh: {keys: [ENV['AWS_SSH_KEY_PATH']]})
    helper.check_existence("#{@remote_directory}/#{File.basename(file)}")
  end

  def upload_sej!(file, helper, scenario_execution, sej)
    helper.exec!("mkdir #{@remote_directory}/#{sej.id}")
    Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, file, "#{@remote_directory}/#{sej.id}/", ssh: {keys: [ENV['AWS_SSH_KEY_PATH']]})
    helper.check_existence("#{@remote_directory}/#{sej.id}/#{File.basename(file)}")
  end

  def copy_dependencies(helper, scenario_execution)
    @jar_executor.dependencies.each do |file|
      upload!(file, helper, scenario_execution)
    end
  end

  def copy_configs(helper, scenario_execution)
    scenario_execution.scenario_execution_jvms.each do |sej|
      path = @local_path_config.scenario_execution_folder(scenario_execution, sej)
      @remote_path_config
      Dir["#{path}/*.*"].each do |file|
        upload_sej!(file, helper, scenario_execution, sej)
      end
    end
  end

  def stop_java_on_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      DeploymentService::EnhancedSSH.start(machine.ip_address, @ssh_user) do |ssh| #, key_data: @machine.private_key
        output = ssh.exec!('whoami')
        raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user
        ssh.exec!('killall java')
      end
    end
  end

  def start_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine
      start_machine(machine, scenario_execution)
    end
  end

  def start_machine(machine, scenario_execution)
    DeploymentService::EnhancedSSH.start(machine.ip_address, @ssh_user) do |ssh| #, key_data: @machine.private_key
      output = ssh.exec!('whoami')
      raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user

      ssh.exec!('killall java')

      scenario_execution.scenario_execution_jvms.each do |sej|
        jars = ssh.exec!("cd \"#{@remote_directory}\" && ls").split(' ').select { |s| s.end_with?('.jar') }.map { |s| "#{@remote_directory}/#{s}" }
        jars << [@remote_path_config.remote_run_jar_path]
        ssh.exec(@jar_executor.command_for_client(jars, sej, @remote_path_config.remote_system_log_dir))
      end

    end
  end
end
