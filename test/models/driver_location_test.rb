require "test_helper"

class DriverLocationTest < ActiveSupport::TestCase
  test "is valid with latitude and longitude" do
    assert driver_locations(:james_location).valid?
  end

  test "is invalid without latitude" do
    loc = driver_locations(:james_location).dup
    loc.latitude = nil
    assert_not loc.valid?
    assert_includes loc.errors[:latitude], "can't be blank"
  end

  test "is invalid without longitude" do
    loc = driver_locations(:james_location).dup
    loc.longitude = nil
    assert_not loc.valid?
    assert_includes loc.errors[:longitude], "can't be blank"
  end

  test "is invalid with latitude out of range" do
    loc = driver_locations(:james_location).dup
    loc.latitude = 91
    assert_not loc.valid?
  end

  test "is invalid with longitude out of range" do
    loc = driver_locations(:james_location).dup
    loc.longitude = 181
    assert_not loc.valid?
  end

  test "belongs to a driver" do
    assert_equal drivers(:james), driver_locations(:james_location).driver
  end
end
