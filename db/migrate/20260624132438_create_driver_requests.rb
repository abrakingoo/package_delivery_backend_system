class CreateDriverRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :driver_requests, id: :uuid do |t|
      t.references :delivery_request, null: false, foreign_key: true, type: :uuid
      t.references :driver, null: false, foreign_key: true, type: :uuid
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
