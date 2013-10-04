class CreateTestMachineConfigs < ActiveRecord::Migration
  def change
    create_table :test_machine_configs do |t|
      t.string :name
      t.text :command_line_arguments
      t.references :test_run, index: true

      t.timestamps
    end
  end
end
