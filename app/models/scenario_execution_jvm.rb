class ScenarioExecutionJvm < ActiveRecord::Base
  include DeploymentService::Downloader

  belongs_to :scenario_execution

  def scenario
    scenario_execution.scenario
  end

  def generate_config_files(path, scenario_execution_mapping)
    config = scenario.config_template
    %w(MLMQ_DB_NAME MLMQ_DB_USER MLMQ_DB_PASSWORD).each do |s|
      config = config.gsub("\#\{#{s}\}", ENV[s])
    end
    config = config.gsub '#{MLMQ_DB_URL}', AwsService.new.resolve_db_url
    config = config.gsub '#{MLMQ_BROKER_MAPPING}', "#{generate_mapping(scenario_execution_mapping, 'broker')}"
    config = config.gsub '#{MLMQ_CLIENT_MAPPING}', "#{generate_mapping(scenario_execution_mapping, 'client')}"
    config = config.gsub '#{MLMQ_SCENARIO_TYPE}', scenario.scenario_type
    config = config.gsub '#{MLMQ_SCENARIO_POSITION}', "#{position}"

    File.open("#{path}/config.properties", 'w') do |f|
      f.puts config
    end

    s = 'https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/testing_logging.properties'
    download_from_uri("#{path}/logging.properties", s)
  end

  def generate_mapping(scenario_execution_mapping, type)
    scenario_execution_mapping.map do |scenario_execution|
      scenario = scenario_execution.scenario
      next unless scenario.scenario_type == type

      scenario_execution.scenario_execution_jvms.map do |sej|
        "#{scenario.name}##{scenario_execution.machine.ip_address}#{type == 'broker' ? ":#{sej.port}" : ''}"
      end.compact.join(';')
    end.compact.join(';')
  end

end
