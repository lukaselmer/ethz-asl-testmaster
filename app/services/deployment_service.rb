require 'net/ssh'

class DeploymentService

  def initialize(test_run)
    @test_run = test_run
    @ssh_user = 'ubuntu'

    raise '@test_run needs to be persistent' if @test_run.id.nil?

    @local_tmp_dir = "#{Rails.root}/tmp/setup/#{@test_run.id}"

    @run_path = "#{@local_tmp_dir}/run"
    @jar_path = "#{@run_path}/run.jar"

    @setup_path = "#{@run_path}/setup"
    @setup_jar_path = "#{@setup_path}/setup.jar"

    @machines_path = "#{@run_path}/machines"

    @git_path = "#{@local_tmp_dir}/git"
    @mvn_path = "#{@git_path}/code/mlmq"
    @compiled_jar_path = "#{@mvn_path}/target/ASL-0.0.1-SNAPSHOT.jar"
    @compiled_dependencies_path = "#{@mvn_path}/target/dependency"

    @remote_test_directory = "/home/ubuntu/messaging_system/tests"
    @remote_directory = "#{@remote_test_directory}/#{@test_run.id}"
    @remote_run_jar_path = "#{@remote_directory}/run.jar"
    @remote_config_properties_path = "#{@remote_directory}/config.properties"
    @remote_logging_properties_path = "#{@remote_directory}/logging.properties"
    @remote_performance_log_dir = "#{@remote_directory}/performance_log"
    @remote_system_log_dir = "#{@remote_directory}/system_log"

    @jar_main_class = 'ch.ethz.mlmq.main.Main'

    raise "Directory #{@local_tmp_dir} already exists" if Dir.exist? @local_tmp_dir

    FileUtils.mkpath @local_tmp_dir
    FileUtils.mkpath @run_path
    FileUtils.mkpath @setup_path
    FileUtils.mkpath @machines_path
  end

  def check_no_other_tests_running!
    TestRun.all.each do |test_run|
      raise "Other test is running already: #{test_run.id}" if test_run.running?
    end
    @test_run.started_at = Time.now
    @test_run.save!
  end

  def check_associated_scenarios!
    @test_run.scenarios.each do |scenario|
      raise "Wrongly associated scenario: #{scenario.id}, was #{scenario.test_run.id}, should #{@test_run.id}" if scenario.test_run.id != @test_run.id
    end
  end

  def start_test
    check_no_other_tests_running!
    check_associated_scenarios!

    m = MachineService.new
    m.ensure_aws_instances(@test_run.total_instances)

    clone_git
    compile_jar
    execute_setup
    mapping = generate_scenario_machine_mapping
    generate_machine_configs(mapping)
    copy_jars_and_configs_to_machines(mapping)
    start_machines(mapping)
  end

  def clone_git
    %x{git clone git@github.com:ganzm/AdvancedSystemsLab2013.git #{@git_path}}
  end

  def compile_jar
    raise "Jar already exists: #{@compiled_jar_path}" if File.exists? @compiled_jar_path
    %x{cd #{@mvn_path} && mvn package}
    %x{cd #{@mvn_path} && mvn dependency:copy-dependencies -DexcludeTypes=test-jar}
    raise "Could not compile jar file: #{@compiled_jar_path}" unless File.exists? @compiled_jar_path
    FileUtils.copy @compiled_jar_path, @jar_path
    FileUtils.copy @compiled_jar_path, @setup_jar_path

  end

  def download_from_uri(dest, source)
    require 'open-uri'
    File.open(dest, 'w') do |f|
      open(source).readlines.each do |line|
        f << line
      end
      yield(f) if block_given?
    end
  end

  def execute_setup
    jars = []
    Dir["#{@compiled_dependencies_path}/*.*"].each do |file|
      dest = "#{@setup_path}/#{File.basename(file)}"
      FileUtils.copy file, dest
      jars << dest
    end
    jars << @setup_jar_path

    s = 'https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/testing_logging.properties'
    logging_properties_path = "#{@setup_path}/logging.properties"
    download_from_uri(logging_properties_path, s)

    common_cmd = "cd \"#{@setup_path}\" && java -cp #{jars.join(':')} #{@jar_main_class} dbscript -url \"#{ENV['MLMQ_DB_URL']}\" -db \"#{ENV['MLMQ_DB_NAME']}\" -user \"#{ENV['MLMQ_DB_USER']}\" -password \"#{ENV['MLMQ_DB_PASSWORD']}\" -l \"#{logging_properties_path}\""

    cmd = "#{common_cmd} -dropDatabase -createDatabase -createTables"
    %x{#{cmd}}
  end

  def generate_scenario_machine_mapping
    machines = Machine.all.to_a
    @test_run.scenarios.collect do |scenario|
      raise 'Scenario id not set' if scenario.id.nil?
      machines.pop(scenario.execution_multiplicity).map { |m| ScenarioExecution.create!(scenario: scenario, machine: m) }
    end.flatten
  end

  def generate_machine_configs(scenario_execution_mapping)
    scenario_execution_mapping.each_with_index do |scenario_execution, index|
      path = "#{@machines_path}/#{scenario_execution.config_folder}"
      FileUtils.mkpath path
      scenario_execution.generate_config_files path, scenario_execution_mapping, index
    end
  end

  def copy_jars_and_configs_to_machines(scenario_execution_mapping)
    require 'net/scp'
    require 'net/ssh'
    require 'deployment_service/ssh_hepler'
    require 'deployment_service/logging_ssh'

    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      Net::SSH.start(machine.ip_address, @ssh_user) do |ssh_raw| #, key_data: @machine.private_key
        ssh = DeploymentService::LoggingSSH.new(ssh_raw)

        begin
          helper = DeploymentService::SSHHelper.new(ssh)
          output = ssh.exec!('whoami')
          raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user

          helper.check_deleted(@remote_directory)

          ssh.exec!("mkdir #{@remote_test_directory}")
          ssh.exec!("mkdir #{@remote_directory}")
          ssh.exec!("mkdir #{@remote_performance_log_dir}")
          ssh.exec!("mkdir #{@remote_system_log_dir}")

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

  def copy_configs(helper, scenario_execution)
    path = "#{@machines_path}/#{scenario_execution.config_folder}"
    Dir["#{path}/*.*"].each do |file|
      Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, file, "#{@remote_directory}/")
      helper.check_existence("#{@remote_directory}/#{File.basename(file)}")
    end
  end

  def copy_dependencies(helper, scenario_execution)
    Dir["#{@compiled_dependencies_path}/*.*"].each do |file|
      Net::SCP.upload!(scenario_execution.machine.ip_address, @ssh_user, file, "#{@remote_directory}/")
      helper.check_existence("#{@remote_directory}/#{File.basename(file)}")
    end
  end

  def start_machines(scenario_execution_mapping)
    require 'net/scp'
    require 'net/ssh'
    require 'deployment_service/ssh_hepler'
    require 'deployment_service/logging_ssh'

    scenario_execution_mapping.each do |scenario_execution|
      machine = scenario_execution.machine

      Net::SSH.start(machine.ip_address, @ssh_user) do |ssh_raw| #, key_data: @machine.private_key
        ssh = DeploymentService::LoggingSSH.new(ssh_raw)

        begin
          output = ssh.exec!('whoami')
          raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == @ssh_user

          ssh.exec!('killall java')

          jars = ssh.exec!("cd \"#{@remote_directory}\" && ls").split(' ').select{|s| s.end_with?('.jar')}.map{|s| "#{@remote_directory}/#{s}"}
          jars << [@remote_run_jar_path]
          ssh.exec("cd \"#{@remote_directory}\" && java -cp \"#{jars.join(':')}\" #{@jar_main_class} \"#{scenario_execution.scenario.name}\" -config \"#{@remote_config_properties_path}\" -l \"#{@remote_logging_properties_path}\" >> \"#{@remote_system_log_dir}/log.log\" 2>&1 &")
        ensure
          puts ssh
        end
      end
    end
  end
end
