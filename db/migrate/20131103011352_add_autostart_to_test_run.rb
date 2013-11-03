class AddAutostartToTestRun < ActiveRecord::Migration
  def change
    add_column :test_runs, :autostart, :boolean, default: true
  end
end
