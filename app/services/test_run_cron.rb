class TestRunCron
  def initialize
    @ssh_user = ENV['AWS_SSH_USER']
  end

  def run
    MachineService.new.sync_aws_instances

    running_test = query_running_test
    if running_test
      return if test_run_still_running? running_test

      # So, the test is not running anymore => stop it and collect logs
      TestRunStopper.new(running_test).stop
    else
      test_to_start = TestRun.ready_to_start.first
      if test_to_start
        start_test test_to_start
      else
        #any_test_ran_until_1_hour_ago = TestRun.where(['ended_at > ?', 1.hour.ago]).any?
        any_test_ran_until_1_hour_ago = TestRun.where(['ended_at > ?', 5.minutes.ago]).any?
        stop_my_machines unless any_test_ran_until_1_hour_ago
      end
    end
  end

  def start_test(test_run)
    DeploymentService.new(test_run).start_test
  end

  def stop_my_machines
    m = MachineService.new
    m.stop_all
  end

  def query_running_test
    tests = TestRun.all.to_a.select do |test_run|
      test_run.running?
    end
    #raise 'Multiple tests are running at the same time!' if tests.size > 1
    tests.first
  end

  def test_run_still_running?(test_run)
    test_run.machines.any? do |machine|
      running_on_machine? machine
    end
  end

  def running_on_machine?(machine)
    DeploymentService::EnhancedSSH.start(machine.ip_address, @ssh_user) do |ssh|
      !ssh.exec!('pgrep java').blank?
    end
  end
end
