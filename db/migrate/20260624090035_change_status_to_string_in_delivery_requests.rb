class ChangeStatusToStringInDeliveryRequests < ActiveRecord::Migration[7.2]
  def change
    change_column :delivery_requests, :status, :string, default: "assigned"
  end
end
