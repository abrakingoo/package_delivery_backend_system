class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses, id: :uuid do |t|
      t.references :delivery_request, null: false, foreign_key: true, type: :uuid
      t.string :address_type
      t.string :street
      t.string :city
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
