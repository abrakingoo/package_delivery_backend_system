class AddAuthFieldsToDrivers < ActiveRecord::Migration[7.2]
  def change
    add_column :drivers, :email, :string
    add_column :drivers, :password_digest, :string
    add_index :drivers, :email, unique: true
  end
end
