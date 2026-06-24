class RefactorAddressColumns < ActiveRecord::Migration[7.2]
  def change
    remove_column :addresses, :address_type, :string
    rename_column :addresses, :street, :pickup_street
    rename_column :addresses, :city, :pickup_city
    rename_column :addresses, :latitude, :pickup_latitude
    rename_column :addresses, :longitude, :pickup_longitude
    add_column :addresses, :delivery_street, :string
    add_column :addresses, :delivery_city, :string
    add_column :addresses, :delivery_latitude, :float
    add_column :addresses, :delivery_longitude, :float
  end
end
