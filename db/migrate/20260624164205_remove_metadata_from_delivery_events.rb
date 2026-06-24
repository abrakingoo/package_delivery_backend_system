class RemoveMetadataFromDeliveryEvents < ActiveRecord::Migration[7.2]
  def change
    remove_column :delivery_events, :metadata, :jsonb
  end
end
