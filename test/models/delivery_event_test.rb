require "test_helper"

class DeliveryEventTest < ActiveSupport::TestCase
  test "is valid with a delivery request and event type" do
    assert delivery_events(:assigned_event).valid?
  end

  test "is invalid without a delivery request" do
    event = DeliveryEvent.new(event_type: "accepted")
    assert_not event.valid?
    assert_includes event.errors[:delivery_request], "must exist"
  end

  test "belongs to a delivery request" do
    assert_equal delivery_requests(:assigned_delivery), delivery_events(:assigned_event).delivery_request
  end
end
