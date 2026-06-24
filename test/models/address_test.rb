require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "belongs to a delivery request" do
    assert_equal delivery_requests(:pending_delivery), addresses(:pending_address).delivery_request
  end

  test "is invalid without a delivery request" do
    address = Address.new(pickup_street: "Kenyatta Ave", pickup_city: "Nairobi")
    assert_not address.valid?
    assert_includes address.errors[:delivery_request], "must exist"
  end
end
