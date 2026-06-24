class DeliveryRequestService
    def self.call(params, user_id, idempotency_key)
        existing = DeliveryRequest.find_by(idempotency_key: idempotency_key)
        return { success: true, request: existing } if existing

        pickup_addr = params[:pick_up_address]
        pickup_address = "#{pickup_addr[:street]}, #{pickup_addr[:city]}, #{pickup_addr[:country]}"
        pickup = GeocodingService.coordinates_for(pickup_address)
        return { success: false, error: "Unable to geocode pickup address" } unless pickup

        delivery_addr = params[:delivery_address]
        delivery_address = "#{delivery_addr[:street]}, #{delivery_addr[:city]}, #{delivery_addr[:country]}"
        delivery = GeocodingService.coordinates_for(delivery_address)
        return { success: false, error: "Unable to geocode delivery address" } unless delivery

        request = DeliveryRequest.create!(
            user_id: user_id,
            idempotency_key: idempotency_key,
            status: "pending",
            package_description: params[:description],
            weight: params[:weight]
        )

        Address.create!(
            delivery_request: request,
            pickup_street: pickup_addr[:street],
            pickup_city: pickup_addr[:city],
            pickup_latitude: pickup[:latitude],
            pickup_longitude: pickup[:longitude],
            delivery_street: delivery_addr[:street],
            delivery_city: delivery_addr[:city],
            delivery_latitude: delivery[:latitude],
            delivery_longitude: delivery[:longitude]
        )

        nearest_drivers = NearestDriverAssignmentService.call(
            request,
            { latitude: pickup[:latitude], longitude: pickup[:longitude] }
        )

        { success: true, request: request, nearestDrivers: nearest_drivers }
    end
end
