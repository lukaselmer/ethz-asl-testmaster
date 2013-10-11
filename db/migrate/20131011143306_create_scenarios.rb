class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.string :name
      t.integer :execution_multiplicity
      t.text :config_template
      t.references :test_run, index: true

      t.timestamps
    end
  end
end
