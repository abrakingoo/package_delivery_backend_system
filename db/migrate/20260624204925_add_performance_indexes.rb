class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :delivery_requests, :status
    add_index :drivers, :available
    add_index :driver_locations, [ :latitude, :longitude ]
    add_index :delivery_events, :created_at
  end
end
