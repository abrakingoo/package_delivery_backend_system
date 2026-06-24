class DeliveryRequestService
    def self.call(params)

        pickup = GeocodingService.coordinates_for(params[:pick_up_address])
        return {
        success: false,
        error: "Unable to geocode pickup address"
        } unless pickup


        delivery = GeocodingService.coordinates_for(params[:delivery_address])
        return {
        success: false,
        error: "Unable to geocode delivery address"
        } unless delivery
        
        Rails.logger.debug pickup.inspect
        Rails.logger.debug delivery.inspect
        params.merge!(
            pickup_latitude: pickup[:latitude],
            pickup_longitude: pickup[:longitude],
            delivery_latitude: delivery[:latitude],
            delivery_longitude: delivery[:longitude]
        )
        return params
    end
end