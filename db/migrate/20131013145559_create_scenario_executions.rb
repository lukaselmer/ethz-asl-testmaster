class CreateScenarioExecutions < ActiveRecord::Migration
  def change
    create_table :scenario_executions do |t|
      t.references :scenario, index: true
      t.references :machine, index: true

      t.timestamps
    end
  end
end
