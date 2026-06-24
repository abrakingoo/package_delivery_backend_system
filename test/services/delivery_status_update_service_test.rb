require "test_helper"

class DeliveryStatusUpdateServiceTest < ActiveSupport::TestCase
  setup do
    @driver = drivers(:james)
    @delivery = delivery_requests(:assigned_delivery)
  end

  test "advances status from assigned to accepted" do
    result = DeliveryStatusUpdateService.call(@delivery, "accepted", @driver)

    assert result[:success]
    assert_equal "accepted", @delivery.reload.status
  end

  test "creates a delivery event on status change" do
    assert_difference "DeliveryEvent.count", 1 do
      DeliveryStatusUpdateService.call(@delivery, "accepted", @driver)
    end

    assert DeliveryEvent.exists?(delivery_request: @delivery, event_type: "accepted")
  end

  test "rejects invalid transitions" do
    result = DeliveryStatusUpdateService.call(@delivery, "delivered", @driver)

    assert_not result[:success]
    assert_match "Invalid transition", result[:error]
  end

  test "marks driver available after delivery is delivered" do
    @delivery.update!(status: "in_transit")

    DeliveryStatusUpdateService.call(@delivery, "delivered", @driver)

    assert_equal true, @driver.reload.available
  end

  test "does not mark driver available on non-delivered transitions" do
    DeliveryStatusUpdateService.call(@delivery, "accepted", @driver)

    assert_equal true, @driver.reload.available
  end

  test "returns error when driver does not own the delivery" do
    other_driver = drivers(:grace)

    result = DeliveryStatusUpdateService.call(@delivery, "accepted", other_driver)

    assert_not result[:success]
    assert_equal "Not your delivery", result[:error]
  end

  test "full lifecycle transitions succeed in order" do
    %w[accepted picked_up in_transit delivered].each do |status|
      result = DeliveryStatusUpdateService.call(@delivery.reload, status, @driver)
      assert result[:success], "Expected transition to #{status} to succeed"
    end
  end
end
