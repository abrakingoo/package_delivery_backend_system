class CreateDeliveryRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_requests, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :driver, null: false, foreign_key: true, type: :uuid
      t.string :package_description
      t.decimal :weight
      t.integer :status

      t.timestamps
    end
  end
end
