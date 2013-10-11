class CreateMachineConfigs < ActiveRecord::Migration
  def change
    create_table :machine_configs do |t|
      t.string :name
      t.text :template

      t.timestamps
    end
  end
end
