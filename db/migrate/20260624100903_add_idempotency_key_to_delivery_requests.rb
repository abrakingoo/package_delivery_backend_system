class AddIdempotencyKeyToDeliveryRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :delivery_requests, :idempotency_key, :string
    add_index :delivery_requests, :idempotency_key, unique: true
  end
end
