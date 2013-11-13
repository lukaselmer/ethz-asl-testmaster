class AnalyzeCron
  def initialize
    @ended_tests = TestRun.all.to_a.select { |test_run| test_run.ended? }
  end

  def run
    @ended_tests.each do |t|
      %w(BTotReqResp).each do |message_type|
        other = {'startup_cooldown_time' => 240000, 'message_type' => message_type}

        l = LogAnalyzerService.new

        puts "Analyzing test run #{t.id} with message type #{message_type}..."
        f = l.analyze(t, 'txt', 1000, other)
        puts "Done analyzing test run #{t.id} with message type #{message_type}, output file #{f}"
      end
    end
  end
end
