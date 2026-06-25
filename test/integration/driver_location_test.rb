require "test_helper"

class DriverLocationTest < ActionDispatch::IntegrationTest
  setup do
    @driver = drivers(:james)
    @token = JwtService.encode(user_id: @driver.id, role: "driver")
    @headers = { "Authorization" => "Bearer #{@token}" }
    @valid_params = { location: { latitude: -1.2921, longitude: 36.8219 } }
  end

  test "driver updates location successfully" do
    patch driver_location_path, params: @valid_params, headers: @headers, as: :json

    assert_response :ok
    assert json_response["location"].present?
    assert_equal(-1.2921, json_response["location"]["latitude"])
    assert_equal 36.8219, json_response["location"]["longitude"]
  end

  test "driver location is persisted in the database" do
    patch driver_location_path, params: @valid_params, headers: @headers, as: :json

    assert_equal(-1.2921, @driver.reload.driver_location.latitude)
  end

  test "fails without authentication" do
    patch driver_location_path, params: @valid_params, as: :json
    assert_response :unauthorized
  end

  test "user cannot update driver location" do
    user_token = JwtService.encode(user_id: users(:john).id, role: "client")

    patch driver_location_path, params: @valid_params,
      headers: { "Authorization" => "Bearer #{user_token}" }, as: :json

    assert_response :forbidden
  end

  test "fails with invalid coordinates" do
    patch driver_location_path, params: { location: { latitude: 999, longitude: 999 } },
      headers: @headers, as: :json

    assert_response :unprocessable_entity
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
