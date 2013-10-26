class AddTypeAndCountPerMachineToScenario < ActiveRecord::Migration
  def change
    add_column :scenarios, :scenario_type, :string, default: 'client'
    add_column :scenarios, :execution_count_per_machine, :integer, null: false, default: 1
  end
end
