class NearestDriverAssignmentService
    def self.call(delivery_request, location)
        nearby_driver_ids = DriverLocation.near(
            [ location[:latitude], location[:longitude] ], 10, order: false
        ).pluck(:driver_id)

        drivers = Driver.where(available: true, id: nearby_driver_ids).limit(10)

        drivers.each do |driver|
            DriverRequest.create!(delivery_request: delivery_request, driver: driver)
        end

        drivers
    end
end
