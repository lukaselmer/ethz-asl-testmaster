class CreateTestRuns < ActiveRecord::Migration
  def change
    create_table :test_runs do |t|
      t.string :state
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
