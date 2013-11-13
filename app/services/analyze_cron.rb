class AnalyzeCron
  def initialize
    @ended_tests = TestRun.all.to_a.select { |test_run| test_run.ended? }
  end

  def run
    @ended_tests.each do |t|
      %w(BTotReqResp).each do |message_type|
        other = {'startup_cooldown_time' => 240000, 'message_type' => message_type}
        output_format = 'txt'

        l = LogAnalyzerService.new
        l.analyze(t, 'txt', 1000, other)
      end
    end
  end
end
