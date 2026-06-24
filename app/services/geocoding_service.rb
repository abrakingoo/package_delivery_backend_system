class GeocodingService
  def self.coordinates_for(address)
    result = Geocoder.search(address).first

    return nil unless result

    {
      latitude: result.latitude,
      longitude: result.longitude
    }
  end
end
