class ScenarioExecution < ActiveRecord::Base
  include DeploymentService::Downloader

  belongs_to :scenario
  belongs_to :machine

  has_many :test_run_logs

  def config_folder
    "#{scenario.id}_#{machine.id}"
  end

  def generate_config_files(path, scenario_execution_mapping, index)
    config = scenario.config_template
    %w(MLMQ_DB_NAME MLMQ_DB_USER MLMQ_DB_PASSWORD).each do |s|
      config = config.gsub("\#\{#{s}\}", ENV[s])
    end
    config = config.gsub '#{MLMQ_DB_URL}', AwsService.new.resolve_db_url

    File.open("#{path}/config.properties", 'w') do |f|
      f.puts config
      f.puts "scenario.mapping = #{generate_mapping(scenario_execution_mapping)}"
      f.puts "scenario.myposition = #{index}"
      f.puts "scenario.mytype = #{scenario.name}"
      f.puts "testrun.id = #{scenario.test_run.id}"
    end

    s = 'https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/testing_logging.properties'
    download_from_uri("#{path}/logging.properties", s)
  end

  def generate_mapping(scenario_execution_mapping)
    ret = {}
    scenario_execution_mapping.collect do |scenario_execution|
      ret[scenario_execution.scenario.name] ||= []
      ret[scenario_execution.scenario.name] << scenario_execution.machine.ip_address
    end
    ret.to_a.collect{|scenario_name, ips| [scenario_name, ips.join(',')].join(':')}.join(';')
  end
end
