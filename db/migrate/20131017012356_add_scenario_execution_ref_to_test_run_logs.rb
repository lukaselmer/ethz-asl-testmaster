class AddScenarioExecutionRefToTestRunLogs < ActiveRecord::Migration
  def change
    add_reference :test_run_logs, :scenario_execution, index: true
  end
end
