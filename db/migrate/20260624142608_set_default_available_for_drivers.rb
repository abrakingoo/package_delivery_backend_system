class SetDefaultAvailableForDrivers < ActiveRecord::Migration[7.2]
  def change
    change_column_default :drivers, :available, from: nil, to: true
    Driver.where(available: nil).update_all(available: true)
  end
end
