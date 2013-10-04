class CreateTestRunLogs < ActiveRecord::Migration
  def change
    create_table :test_run_logs do |t|
      t.datetime :logged_at
      t.string :message_type
      t.text :message_content
      t.integer :execution_in_microseconds
      t.references :test_run, index: true
      t.references :test_machine_config, index: true

      t.timestamps
    end
  end
end
