class CreateTestRuns < ActiveRecord::Migration
  def change
    create_table :test_runs do |t|
      t.string :name
      t.datetime :started_at
      t.datetime :ended_at
      t.text :config

      t.timestamps
    end
  end
end
