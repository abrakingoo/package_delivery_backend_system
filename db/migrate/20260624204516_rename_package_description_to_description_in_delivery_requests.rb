class RenamePackageDescriptionToDescriptionInDeliveryRequests < ActiveRecord::Migration[7.2]
  def change
    rename_column :delivery_requests, :package_description, :description
  end
end
