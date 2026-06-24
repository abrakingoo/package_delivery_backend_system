require "test_helper"

class DeliveryRequestTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john)
    @token = JwtService.encode(user_id: @user.id, role: "client")
    @headers = { "Authorization" => "Bearer #{@token}", "Idempotency-Key" => "unique-key-#{SecureRandom.hex(4)}" }
    @valid_params = {
      delivery_request: {
        description: "Laptop",
        weight: 2.5,
        pick_up_address: { street: "Kenyatta Avenue", city: "Nairobi", country: "Kenya" },
        delivery_address: { street: "Moi Avenue", city: "Nairobi", country: "Kenya" }
      }
    }
  end

  test "creates delivery request successfully" do
    post delivery_request_path, params: @valid_params, headers: @headers, as: :json
    assert_response :created
    assert json_response["response"].present?
  end

  test "returns existing request on duplicate idempotency key" do
    existing = delivery_requests(:pending_delivery)
    headers = @headers.merge("Idempotency-Key" => existing.idempotency_key)

    post delivery_request_path, params: @valid_params, headers: headers, as: :json

    assert_response :created
    assert_equal existing.id, json_response["response"]["id"]
  end

  test "fails without idempotency key" do
    post delivery_request_path, params: @valid_params,
      headers: { "Authorization" => "Bearer #{@token}" }, as: :json

    assert_response :bad_request
    assert_equal "Idempotency-Key header is required", json_response["error"]
  end

  test "fails without authentication" do
    post delivery_request_path, params: @valid_params, as: :json
    assert_response :unauthorized
  end

  test "fails with missing required fields" do
    post delivery_request_path, params: { delivery_request: { description: "Laptop" } },
      headers: @headers, as: :json

    assert_response :unprocessable_entity
    assert json_response["error"].include?("Missing required fields")
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
