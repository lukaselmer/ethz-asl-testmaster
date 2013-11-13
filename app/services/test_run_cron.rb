class TestRunCron
  def initialize
    @ssh_user = ENV['AWS_SSH_USER']
    @machine_service = MachineService.new
  end

  def run
    @machine_service.sync_aws_instances

    running_test = query_running_test
    if running_test
      return if test_run_still_running? running_test

      puts "#{Time.now}: Stopping test #{running_test.id}"
      # So, the test is not running anymore => stop it and collect logs
      TestRunStopper.new(running_test).stop
      running_test.machines.each do |m|
        kill_logs(m)
      end
    else
      test_to_start = TestRun.ready_to_start.first
      if test_to_start
        puts "#{Time.now}: Starting test #{test_to_start.id}"
        start_test test_to_start
      else
        any_test_ran_until_1_hour_ago = TestRun.where(['ended_at > ?', 30.minutes.ago]).any?
        return if any_test_ran_until_1_hour_ago
        puts "#{Time.now}: Shutting down machines"
        stop_my_machines
        @machine_service.sync_aws_instances
      end
    end
  end

  def kill_logs(machine)
    DeploymentService::EnhancedSSH.start(machine.ip_address, @ssh_user) do |ssh|
      ssh.exec!('rm -rf /home/ubuntu/messaging_system/tests')
      ssh.exec!('mkdir /home/ubuntu/messaging_system/tests')
      !ssh.exec!('pgrep java').blank?
    end
  end

  def start_test(test_run)
    DeploymentService.new(test_run).start_test
  end

  def stop_my_machines
    @machine_service.stop_all
  end

  def query_running_test
    tests = TestRun.all.to_a.select do |test_run|
      s = test_run.state
      s == :running || s == :stopped
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
      # Hack / workaround!
      #(110..151).each do |v|
      #  ssh.exec!("rm -rf /home/ubuntu/messaging_system/tests/#{v}")
      #end
      !ssh.exec!('pgrep java').blank?
    end
  end
end
