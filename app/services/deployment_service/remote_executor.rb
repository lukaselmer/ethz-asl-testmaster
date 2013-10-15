class DeploymentService::RemoteExecutor

  def initialize(test_run, machine)
    @test_run = test_run
    @machine = machine
  end

  def execute_test
    Net::SSH.start(@machine.host, 'ubuntu') do |ssh_raw| #, key_data: @machine.private_key
      ssh = DeploymentService::EnhancedSSH.new(ssh_raw)

      begin
        output = ssh.exec!('whoami')
        raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == 'ubuntu'

        testdir = "/home/ubuntu/messaging_system/tests/#{@test_run.id}"
        ssh.check_deleted(testdir)

        ssh.exec!("mkdir #{testdir}")
        ssh.exec!("mkdir #{testdir}/log")

        ssh.exec!('cd /home/ubuntu/messaging_system/code && git pull')

        ssh.delete('/home/ubuntu/messaging_system/code/code/mlmq/target/ASL-0.0.1-SNAPSHOT.jar')

        ssh.exec!('cd /home/ubuntu/messaging_system/code/code/mlmq && mvn package')
        compile_jar_path = '/home/ubuntu/messaging_system/code/code/mlmq/target/ASL-0.0.1-SNAPSHOT.jar'
        ssh.check_existence(compile_jar_path)

        run_jar_path = "#{testdir}/runner.jar"
        ssh.exec!("cp #{compile_jar_path} #{run_jar_path}")

        ssh.exec!("cd /home/ubuntu/messaging_system/tests/#{@test_run.id} && java -jar #{run_jar_path} #{@machine.profile}")
      ensure
        puts ssh
      end
    end
  end
end
