class AnalyzeCron
  def initialize
    @ended_tests = ended_tests
  end

  def ended_tests
    TestRun.all.to_a.select { |test_run| test_run.ended? }
  end

  def run
    @ended_tests.each do |t|
      return if @ended_tests.size < ended_tests.size

      %w(BTotReqResp).each do |message_type|
        other = {'startup_cooldown_time' => 240000, 'message_type' => message_type}

        l = LogAnalyzerService.new

        puts "Analyzing test run #{t.id} with message type #{message_type}..."
        begin
          f = l.analyze(t, 'txt', 1000, other)
          puts "Done analyzing test run #{t.id} with message type #{message_type}, output file #{f}"
        rescue Exception => e
          puts "Error analyzing test run #{t.id} with message type #{message_type}: #{e}"
          puts e.message
          puts e.backtrace.join("\n")
        end
      end
    end
  end
end
