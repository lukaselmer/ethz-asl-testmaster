require 'spec_helper'

def download_from_uri(dest, source)
  require 'open-uri'
  File.open(dest, 'w') do |f|
    open(source).readlines.each do |line|
      f << line
    end
    yield(f) if block_given?
  end
end

def generate_config_file_for_broker
  require 'open-uri'
  s = 'https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/brokerconfig.template.properties'
  lines = open(s).readlines.map { |s| s.strip }
  lines << 'db.url= #{MLMQ_DB_URL}'
  lines << 'db.name= #{MLMQ_DB_NAME}'
  lines << 'db.username= #{MLMQ_DB_USER}'
  lines << 'db.password= #{MLMQ_DB_PASSWORD}'
  lines << ''
  lines.join("\r\n")
end

describe 'Deplyoment service' do
  it 'should initialize the depoyment service' do
    if false
      begin
        test_run = TestRun.create!(name: 'first test')

        test_run.scenarios << Scenario.create!(name: 'broker', execution_multiplicity: 1,
                                               config_template: generate_config_file_for_broker, test_run: test_run)
        #test_run.scenarios << Scenario.create!(name: 'scenario2', execution_multiplicity: 1, config_template: 'blub\nblubb', test_run: test_run)
        test_run.save!
        DeploymentService.new(test_run).start_test
      rescue Exception => e
        p e
        raise e
      end
    end
  end

  it 'should have a cmd executor which can execute and log commands' do
    c = DeploymentService::CmdExecutor.new
    ret = c.exec!('echo "test"')
    ret.strip.should eq('test')
    c.to_s.split("\n")[2].should eq('> echo "test"')
    c.to_s.split("\n")[3].should eq('test')
  end
end
