require "test_helper"

class NearestDriverAssignmentServiceTest < ActiveSupport::TestCase
  setup do
    @delivery = delivery_requests(:pending_delivery)
    @pickup_location = { latitude: -1.2921, longitude: 36.8219 }
  end

  test "creates driver requests for available nearby drivers" do
    assert_difference "DriverRequest.count", 2 do
      NearestDriverAssignmentService.call(@delivery, @pickup_location)
    end
  end

  test "returns the list of assigned drivers" do
    drivers = NearestDriverAssignmentService.call(@delivery, @pickup_location)
    assert drivers.all? { |d| d.available }
  end

  test "does not assign unavailable drivers" do
    drivers(:james).update_column(:available, false)

    drivers = NearestDriverAssignmentService.call(@delivery, @pickup_location)
    assert drivers.none? { |d| d.id == drivers(:james).id }
  end

  test "does not assign drivers outside the radius" do
    # move grace far away from pickup (Mombasa)
    driver_locations(:grace_location).update!(latitude: -4.0435, longitude: 39.6682)

    drivers = NearestDriverAssignmentService.call(@delivery, @pickup_location)
    assert drivers.none? { |d| d.id == drivers(:grace).id }
  end

  test "returns empty array when no available drivers are nearby" do
    Driver.update_all(available: false)

    drivers = NearestDriverAssignmentService.call(@delivery, @pickup_location)
    assert_empty drivers
  end
end
