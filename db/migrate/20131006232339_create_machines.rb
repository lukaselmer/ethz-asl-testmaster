class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :test_state

      t.string :ip_address
      t.string :owner_id
      t.datetime :launch_time
      t.string :instance_type
      t.string :instance_id
      t.string :dns_name
      t.string :status
      t.string :availability_zone
      t.string :user_data

      t.timestamps
    end
  end
end
