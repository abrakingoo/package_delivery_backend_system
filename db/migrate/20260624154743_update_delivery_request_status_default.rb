class UpdateDeliveryRequestStatusDefault < ActiveRecord::Migration[7.2]
  def change
    change_column_default :delivery_requests, :status, from: "assigned", to: "pending"
  end
end
