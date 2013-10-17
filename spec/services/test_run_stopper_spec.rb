require 'spec_helper'

describe 'Test run stopper' do
  it 'should call stop_scenario_execution and collect_logs methods when stopping' do
    se1 = ScenarioExecution.new(id: 1)
    se2 = ScenarioExecution.new(id: 2)
    se3 = ScenarioExecution.new(id: 3)

    sc1 = Scenario.new(scenario_executions: [se1, se2])
    sc2 = Scenario.new(scenario_executions: [se3])

    test_run = TestRun.new(started_at: Time.now, scenarios: [sc1, sc2])

    t = TestRunStopper.new(test_run, 0)

    t.should_receive(:stop_scenario_execution).with(se1)
    t.should_receive(:stop_scenario_execution).with(se2)
    t.should_receive(:stop_scenario_execution).with(se3)

    t.should_receive(:collect_logs).with(se1)
    t.should_receive(:collect_logs).with(se2)
    t.should_receive(:collect_logs).with(se3)

    t.should_receive(:analyze_logs).with(se1)
    t.should_receive(:analyze_logs).with(se2)
    t.should_receive(:analyze_logs).with(se3)

    t.stop
  end

  it 'should resolve an ip address for the aws db id' do
    MachineService.any_instance.stub(:resolve_instance_ip_address) { '1.2.3.4' }

    ENV['MLMQ_DB_URL'].should include('#{host}')

    AwsService.new.resolve_db_url.should eq(ENV['MLMQ_DB_URL'].gsub('#{host}', '1.2.3.4'))
  end

  it 'should set the status to ended after collecting the log files' do
    se1 = ScenarioExecution.new(id: 1)

    sc1 = Scenario.new(scenario_executions: [se1])

    test_run = TestRun.new(started_at: Time.now, scenarios: [sc1])

    t = TestRunStopper.new(test_run, 0)
    t.stub(:stop_scenario_execution)
    t.stub(:collect_logs)
    t.stub(:analyze_logs)

    test_run.stopped_at.should be(nil)
    test_run.ended_at.should be(nil)

    t.stop

    test_run.stopped_at.should_not be(nil)
    test_run.ended_at.should_not be(nil)
  end

  it 'should analyze the log files' do
    lines = "1;20131017010210;SendResponse\n73;20131017010210;TotalRequestResponse\n64;20131017010210;ProcessRequest#RegistrationRequest:RegistrationResponse"
    require 'tempfile'
    file = Tempfile.new('foo')
    path = file.path
    begin
      file << lines
      file.close
      expect {
        TestRunStopper::LogAnalyzer.new(TestRun.new(id: 1), ScenarioExecution.new(id: 2)).analyze_log(path)
      }.to change(TestRunLog, :count).by(3)
    ensure
      File.delete path
    end
  end

  it 'should parse a log line' do
    line = "384;20131017010210;SendResponse"
    res = TestRunStopper::LogAnalyzer.new(nil, nil).parse_line line
    res.should be_a(Hash)
    res.size.should eq(3)
    res[:logged_at].should eq(DateTime.new(2013, 10, 17, 1, 2, 10))
    res[:execution_in_microseconds].to_i.should eq(384)
    res[:message_type].should eq('SendResponse')
  end

end


