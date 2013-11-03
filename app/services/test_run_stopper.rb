class TestRunStopper

  def initialize(test_run, sleep_between_stop_and_log_collection = 12)
    @test_run = test_run
    @sleep_between_stop_and_log_collection = sleep_between_stop_and_log_collection
  end

  def stop
    raise "Test run #{@test_run.id} is not running!" unless @test_run.running?
    @test_run.update_attribute :stopped_at, Time.now
    scenario_executions = @test_run.scenarios.collect { |s| s.scenario_executions.to_a }.flatten
    scenario_executions.each { |se| stop_scenario_execution(se) }
    sleep @sleep_between_stop_and_log_collection
    scenario_executions.each { |se| collect_logs(se) }
    @test_run.update_attribute :ended_at, Time.now
    #scenario_executions.each { |se| analyze_logs(se) }
  end

  private

  def stop_scenario_execution(scenario_execution)
    TestRunStopper::ScenarioExecutionStopper.new(@test_run, scenario_execution).stop_scenario
  end

  def collect_logs(scenario_execution)
    TestRunStopper::LogCollector.new(@test_run, scenario_execution).collect_logs
  end

  #def analyze_logs(scenario_execution)
  #  TestRunStopper::LogAnalyzer.new(@test_run, scenario_execution).analyze_logs
  #end
end
