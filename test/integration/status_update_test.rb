require "test_helper"

class StatusUpdateTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:james)
    @user = users(:john)
    @driver_token = JwtService.encode(user_id: @driver.id, role: "driver")
    @user_token = JwtService.encode(user_id: @user.id, role: "client")
    @driver_headers = { "Authorization" => "Bearer #{@driver_token}" }
    @user_headers = { "Authorization" => "Bearer #{@user_token}" }

    @delivery = delivery_requests(:assigned_delivery)
  end

  # Status transitions
  test "driver advances status from assigned to accepted" do
    patch deliveries_update_status_path(@delivery.id), params: { status: "accepted" },
      headers: @driver_headers, as: :json

    assert_response :ok
    assert_equal "accepted", @delivery.reload.status
    assert DeliveryEvent.exists?(delivery_request: @delivery, event_type: "accepted")
  end

  test "driver cannot skip status transitions" do
    patch deliveries_update_status_path(@delivery.id), params: { status: "delivered" },
      headers: @driver_headers, as: :json

    assert_response :unprocessable_entity
    assert json_response["error"].include?("Invalid transition")
  end

  test "driver is marked available after delivery is delivered" do
    @delivery.update!(status: "in_transit")

    patch deliveries_update_status_path(@delivery.id), params: { status: "delivered" },
      headers: @driver_headers, as: :json

    assert_response :ok
    assert_equal true, @driver.reload.available
  end

  test "user cannot update delivery status" do
    patch deliveries_update_status_path(@delivery.id), params: { status: "accepted" },
      headers: @user_headers, as: :json

    assert_response :forbidden
  end

  # Tracking
  test "user fetches all their deliveries" do
    get deliveries_path, headers: @user_headers, as: :json

    assert_response :ok
    assert json_response.is_a?(Array)
  end

  test "user fetches a single delivery" do
    get delivery_path(@delivery.id), headers: @user_headers, as: :json

    assert_response :ok
    assert_equal @delivery.id, json_response["id"]
    assert json_response["status"].present?
  end

  test "user fetches delivery event history" do
    DeliveryEvent.create!(delivery_request: @delivery, event_type: "accepted")

    get delivery_events_path(@delivery.id), headers: @user_headers, as: :json

    assert_response :ok
    assert json_response.is_a?(Array)
    assert_equal "accepted", json_response.last["event_type"]
  end

  test "user cannot view another user's delivery" do
    other_user_token = JwtService.encode(user_id: users(:jane).id, role: "client")

    get delivery_path(@delivery.id), headers: { "Authorization" => "Bearer #{other_user_token}" }, as: :json

    assert_response :not_found
  end

  test "returns 404 for non-existent delivery" do
    get delivery_path(SecureRandom.uuid), headers: @user_headers, as: :json
    assert_response :not_found
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
