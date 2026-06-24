class DriverLocationService
  def self.call(driver, params)
    location = DriverLocation.find_or_initialize_by(driver: driver)
    location.assign_attributes(
      latitude: params[:latitude],
      longitude: params[:longitude]
    )

    if location.save
      { success: true, location: location }
    else
      { success: false, error: location.errors.full_messages }
    end
  end
end
