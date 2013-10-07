class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :host
      t.string :profile
      t.string :state
      t.text :private_key
      t.text :additional_info

      t.timestamps
    end
  end
end
