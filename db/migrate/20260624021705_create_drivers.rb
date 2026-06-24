class CreateDrivers < ActiveRecord::Migration[7.2]
  def change
    create_table :drivers, id: :uuid do |t|
      t.string :name
      t.string :phone
      t.boolean :available

      t.timestamps
    end
  end
end
