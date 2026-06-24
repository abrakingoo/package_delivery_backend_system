class MakeDriverOptionalInDeliveryRequests < ActiveRecord::Migration[7.2]
  def change
    change_column_null :delivery_requests, :driver_id, true
  end
end
