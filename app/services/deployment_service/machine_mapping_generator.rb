module DeploymentService::MachineMappingGenerator
  def generate_scenario_machine_mapping(test_run)
    machines = Machine.all.to_a
    test_run.scenarios.collect do |scenario|
      raise 'Scenario id not set' if scenario.id.nil?
      machines.pop(scenario.execution_multiplicity).map { |m| ScenarioExecution.create!(scenario: scenario, machine: m) }
    end.flatten
  end
end
