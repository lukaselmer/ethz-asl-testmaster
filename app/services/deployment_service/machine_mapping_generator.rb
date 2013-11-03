module DeploymentService::MachineMappingGenerator
  def generate_scenario_machine_mapping(test_run)
    MachineService.new.sync_aws_instances

    counters = {}
    machines = Machine.ready.order('instance_id asc').to_a
    test_run.scenarios.collect do |scenario|
      raise 'Scenario id not set' if scenario.id.nil?
      t = scenario.scenario_type

      counters[t] ||= 0
      if machines.count < scenario.execution_multiplicity
        s = "machines.count (#{machines.count}) < scenario.execution_multiplicity (#{scenario.execution_multiplicity})! Total machines count: #{Machine.ready.count}, "
        raise s
      end
      machines.pop(scenario.execution_multiplicity).collect { |m| create_scenario_execution!(scenario, m, counters, t) }
    end.flatten
  end

  private

  def create_scenario_execution!(scenario, m, counters, t)
    se = ScenarioExecution.new(scenario: scenario, machine: m)
    se.exec_ids.each do |exec_id|
      se.scenario_execution_jvms << ScenarioExecutionJvm.new(position: counters[t], scenario_execution: se, port: port_for(exec_id))
      counters[t] += 1
    end
    se.save!
    se
  end

  def port_for(exec_id)
    starting_port = ENV['MLMQ_STARTING_PORT'].to_i
    starting_port + exec_id
  end
end
