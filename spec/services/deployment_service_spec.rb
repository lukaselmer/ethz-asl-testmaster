require 'spec_helper'

include DeploymentService::Downloader

def generate_config_file_for_broker(filename)
  require 'open-uri'
  s = "https://raw.github.com/ganzm/AdvancedSystemsLab2013/master/code/mlmq/resource/#{filename}"
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
    if RUBY_PLATFORM =~ /darwin/i && false # only execute this test locally
      begin
        test_run = TestRun.create!(name: 'first test')

        test_run.scenarios << Scenario.create!(name: 'broker', execution_multiplicity: 1, test_run: test_run,
                                               config_template: generate_config_file_for_broker('brokerconfig.template.properties'))
        test_run.scenarios << Scenario.create!(name: 'client', execution_multiplicity: 1, test_run: test_run,
                                               config_template: generate_config_file_for_broker('clientconfig.template.properties'))
        test_run.save!
        DeploymentService.new(test_run).start_test
        sleep 30
        TestRunStopper.new(test_run).stop
      rescue Exception => e
        p e
        raise e
      end
    end
  end

  #it 'should have a cmd executor which can execute and log commands' do
  #  c = DeploymentService::CmdExecutor.new
  #  ret = c.exec!('echo "test"')
  #  ret.strip.should eq('test')
  #  c.to_s.split("\n")[2].should eq('> echo "test"')
  #  c.to_s.split("\n")[3].should eq('test')
  #end
end
