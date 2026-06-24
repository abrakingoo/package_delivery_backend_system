class CreateDriverLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :driver_locations, id: :uuid do |t|
      t.references :driver, null: false, foreign_key: true, type: :uuid
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
