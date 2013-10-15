require 'net/scp'
require 'net/ssh'

class DeploymentService
  include DeploymentService::MachineMappingGenerator
  include DeploymentService::Downloader

  def initialize(test_run)

    @test_run = test_run
    @ssh_user = 'ubuntu'

    @cmd_executor = DeploymentService::CmdExecutor.new

    raise '@test_run needs to be persistent' if @test_run.id.nil?

    @local_tmp_dir = "#{Rails.root}/tmp/setup/#{@test_run.id}"
    raise "Directory #{@local_tmp_dir} already exists" if Dir.exist? @local_tmp_dir

    @run_path = "#{@local_tmp_dir}/run"
    @jar_path = "#{@run_path}/run.jar"

    @setup_path = "#{@run_path}/setup"

    @machines_path = "#{@run_path}/machines"

    @remote_test_directory = "/home/ubuntu/messaging_system/tests"
    @remote_directory = "#{@remote_test_directory}/#{@test_run.id}"
    @remote_run_jar_path = "#{@remote_directory}/run.jar"
    @remote_performance_log_dir = "#{@remote_directory}/performance_log"
    @remote_system_log_dir = "#{@remote_directory}/system_log"

    @git_cloner = DeploymentService::GitCloner.new(@cmd_executor, @local_tmp_dir)
    @jar_compiler = DeploymentService::JarCompiler.new(@cmd_executor, @git_cloner.git_path, @jar_path, @setup_path)
    @jar_executor = DeploymentService::JarExecutor.new(@cmd_executor, @jar_compiler, @remote_directory)

    [@local_tmp_dir, @run_path, @setup_path, @machines_path].each { |d| FileUtils.mkpath d }
  end

  def start_test
    begin
      check_no_other_tests_running!
      mark_as_started!
      check_associated_scenarios!

      m = MachineService.new
      m.ensure_aws_instances(@test_run.total_instances)

      mapping = generate_scenario_machine_mapping(@test_run)
      stop_java_on_machines(mapping)
      @git_cloner.clone_git
      @jar_compiler.compile_jar
      @jar_executor.execute_setup
      generate_machine_configs(mapping)
      copy_jars_and_configs_to_machines(mapping)
      start_machines(mapping)
    ensure
      puts @cmd_executor.to_s
    end
  end

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
    scenario_execution_mapping.each_with_index do |scenario_execution, index|
      path = "#{@machines_path}/#{scenario_execution.config_folder}"
      FileUtils.mkpath path
      scenario_execution.generate_config_files path, scenario_execution_mapping, index
    end
  end

  def copy_jars_and_configs_to_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      raise "Machine #{machine.instance_id} doesn't have an ip!" if machine.ip_address.to_s.blank?

      Net::SSH.start(machine.ip_address, @ssh_user) do |ssh_raw| #, key_data: @machine.private_key
        ssh = DeploymentService::LoggingSSH.new(ssh_raw)

        begin
          helper = DeploymentService::EnhancedSSH.new(ssh)
          output = ssh.exec!('whoami')
          raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user

          helper.check_deleted(@remote_directory)

          [@remote_test_directory, @remote_directory, @remote_performance_log_dir, @remote_system_log_dir].each do |f|
            ssh.exec!("mkdir #{f}")
          end

          copy_jar(helper, scenario_execution)
          copy_dependencies(helper, scenario_execution)
          copy_configs(helper, scenario_execution)
        ensure
          puts ssh
        end
      end
    end

  end

  def copy_jar(helper, scenario_execution)
    Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, @jar_path, @remote_run_jar_path)
    helper.check_existence(@remote_run_jar_path)
  end

  def upload!(file, helper, scenario_execution)
    Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, file, "#{@remote_directory}/")
    helper.check_existence("#{@remote_directory}/#{File.basename(file)}")
  end

  def copy_dependencies(helper, scenario_execution)
    @jar_executor.dependencies.each do |file|
      upload!(file, helper, scenario_execution)
    end
  end

  def copy_configs(helper, scenario_execution)
    path = "#{@machines_path}/#{scenario_execution.config_folder}"
    Dir["#{path}/*.*"].each do |file|
      upload!(file, helper, scenario_execution)
    end
  end

  def stop_java_on_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      Net::SSH.start(machine.ip_address, @ssh_user) do |ssh_raw| #, key_data: @machine.private_key
        ssh = DeploymentService::LoggingSSH.new(ssh_raw)

        begin
          output = ssh.exec!('whoami')
          raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user
          ssh.exec!('killall java')
        ensure
          puts ssh
        end
      end
    end
  end

  def start_machines(scenario_execution_mapping)
    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      Net::SSH.start(machine.ip_address, @ssh_user) do |ssh_raw| #, key_data: @machine.private_key
        ssh = DeploymentService::LoggingSSH.new(ssh_raw)

        begin
          output = ssh.exec!('whoami')
          raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user

          ssh.exec!('killall java')

          jars = ssh.exec!("cd \"#{@remote_directory}\" && ls").split(' ').select { |s| s.end_with?('.jar') }.map { |s| "#{@remote_directory}/#{s}" }
          jars << [@remote_run_jar_path]

          ssh.exec(@jar_executor.command_for_client(jars, scenario_execution, @remote_system_log_dir))
        ensure
          puts ssh
        end
      end
    end
  end
end
