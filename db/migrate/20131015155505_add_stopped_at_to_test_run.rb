class AddStoppedAtToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :stopped_at, :datetime
  end
end
