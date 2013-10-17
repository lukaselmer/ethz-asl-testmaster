class TestRunStopper::LogAnalyzer
  def initialize(test_run, scenario_execution)
    @test_run = test_run
    @scenario_execution = scenario_execution
    @local_path_config = DeploymentService::LocalPathConfig.new(test_run)
  end

  def analyze_logs
    analyze_logs_rec @local_path_config.scenario_execution_logs_path(@scenario_execution)
  end

  def analyze_logs_rec(path)
    Dir["#{path}/**"].each do |d|
      p = "#{path}/#{d}"
      analyze_logs_rec p if Dir.exists?(p)
      analyze_log p if p.ends_with?('.log') && File.exists?(p)
    end
  end

  def analyze_log(logfile_path)
    log_objects = []
    File.open(logfile_path, 'r').each_line do |line|
      log_objects << parse_line(line)
      if log_objects.size >= 1000
        persist_log_objects(log_objects)
        log_objects = []
      end
    end
    persist_log_objects(log_objects)
  end

  def persist_log_objects(objects)
    TestRunLog.create!(objects) do |o|
      o.test_run_id = @test_run.id
      o.scenario_execution_id = @scenario_execution.id
    end
  end

  def parse_line(line)
    return if line.strip.blank?
    execution, logged_at, message_type = line.strip.split(';', 3)
    {logged_at: DateTime.parse(logged_at), message_type: message_type.strip, execution_in_microseconds: execution}
  end
end
