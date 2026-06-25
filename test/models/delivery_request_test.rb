require "test_helper"

class DeliveryRequestModelTest < ActiveSupport::TestCase
  test "is valid with a valid status" do
    assert delivery_requests(:pending_delivery).valid?
  end

  test "is invalid with an unknown status" do
    dr = delivery_requests(:pending_delivery)
    dr.status = "flying"
    assert_not dr.valid?
    assert_includes dr.errors[:status], "is not included in the list"
  end

  test "can_transition_to? returns true for valid next step" do
    dr = delivery_requests(:assigned_delivery)
    assert dr.can_transition_to?("accepted")
  end

  test "can_transition_to? returns false for invalid step" do
    dr = delivery_requests(:assigned_delivery)
    assert_not dr.can_transition_to?("delivered")
  end

  test "next_status returns correct following status" do
    dr = delivery_requests(:pending_delivery)
    assert_equal "assigned", dr.next_status
  end

  test "next_status returns nil for delivered" do
    dr = delivery_requests(:assigned_delivery)
    dr.status = "delivered"
    assert_nil dr.next_status
  end

  test "belongs to a user" do
    assert_equal users(:john), delivery_requests(:pending_delivery).user
  end
end
