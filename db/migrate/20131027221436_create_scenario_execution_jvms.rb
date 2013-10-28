class CreateScenarioExecutionJvms < ActiveRecord::Migration
  def change
    create_table :scenario_execution_jvms do |t|
      t.references :scenario_execution
      t.integer :port
      t.integer :position

      t.timestamps
    end
  end
end
