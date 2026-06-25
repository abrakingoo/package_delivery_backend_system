require "test_helper"

class DriverAssignmentTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:james)
    @token = JwtService.encode(user_id: @driver.id, role: "driver")
    @headers = { "Authorization" => "Bearer #{@token}" }

    @delivery = delivery_requests(:pending_delivery)
    @driver_request = DriverRequest.create!(delivery_request: @delivery, driver: @driver, status: "pending")
  end

  test "driver accepts a delivery request" do
    patch driver_requests_respond_path(@delivery.id), params: { response_action: "accept" },
      headers: @headers, as: :json

    assert_response :ok
    assert_equal "accepted", @driver_request.reload.status
    assert_equal "assigned", @delivery.reload.status
    assert_equal false, @driver.reload.available
  end

  test "driver rejects a delivery request" do
    patch driver_requests_respond_path(@delivery.id), params: { response_action: "reject" },
      headers: @headers, as: :json

    assert_response :ok
    assert_equal "rejected", @driver_request.reload.status
  end

  test "driver cannot respond twice to same request" do
    @driver_request.update!(status: "accepted")

    patch driver_requests_respond_path(@delivery.id), params: { response_action: "accept" },
      headers: @headers, as: :json

    assert_response :unprocessable_entity
    assert_equal "Already responded", json_response["error"]
  end

  test "user cannot respond to driver request" do
    user_token = JwtService.encode(user_id: users(:john).id, role: "client")

    patch driver_requests_respond_path(@driver.id), params: { response_action: "accept" },
      headers: { "Authorization" => "Bearer #{user_token}" }, as: :json

    assert_response :forbidden
  end

  test "returns 404 for non-existent driver request" do
    patch driver_requests_respond_path(SecureRandom.uuid), params: { response_action: "accept" },
      headers: @headers, as: :json

    assert_response :not_found
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
