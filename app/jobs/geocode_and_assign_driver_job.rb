class GeocodeAndAssignDriverJob < ApplicationJob
  queue_as :default

  def perform(delivery_request_id, pickup_addr, delivery_addr)
    request = DeliveryRequest.find_by(id: delivery_request_id)
    return unless request

    pickup_string = "#{pickup_addr["street"]}, #{pickup_addr["city"]}, #{pickup_addr["country"]}"
    pickup = GeocodingService.coordinates_for(pickup_string)

    unless pickup
      request.update!(status: "no_driver_found")
      return
    end

    delivery_string = "#{delivery_addr["street"]}, #{delivery_addr["city"]}, #{delivery_addr["country"]}"
    delivery = GeocodingService.coordinates_for(delivery_string)

    unless delivery
      request.update!(status: "no_driver_found")
      return
    end

    Address.create!(
      delivery_request: request,
      pickup_street:    pickup_addr["street"],
      pickup_city:      pickup_addr["city"],
      pickup_latitude:  pickup[:latitude],
      pickup_longitude: pickup[:longitude],
      delivery_street:  delivery_addr["street"],
      delivery_city:    delivery_addr["city"],
      delivery_latitude:  delivery[:latitude],
      delivery_longitude: delivery[:longitude]
    )

    NearestDriverAssignmentService.call(
      request,
      { latitude: pickup[:latitude], longitude: pickup[:longitude] }
    )
  end
end
