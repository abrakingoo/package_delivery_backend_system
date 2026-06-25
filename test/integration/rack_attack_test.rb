require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.enabled = true
    @cache = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.cache.store = @cache
  end

  teardown do
    @cache.clear
    Rack::Attack.enabled = false
  end

  test "throttles login after 5 attempts from same IP" do
    5.times do
      post auth_login_path, params: { user: { email: "john@example.com", password: "wrongpassword" } },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }, as: :json
    end

    post auth_login_path, params: { user: { email: "john@example.com", password: "wrongpassword" } },
      headers: { "REMOTE_ADDR" => "1.2.3.4" }, as: :json
    assert_response 429
    assert_equal "Too many requests. Please try again later.", json_response["error"]
  end

  test "throttles login after 5 attempts with same email from different IPs" do
    5.times do |i|
      post auth_login_path, params: { user: { email: "john@example.com", password: "wrongpassword" } },
        headers: { "REMOTE_ADDR" => "10.0.0.#{i + 1}" }, as: :json
    end

    post auth_login_path, params: { user: { email: "john@example.com", password: "wrongpassword" } },
      headers: { "REMOTE_ADDR" => "10.0.0.99" }, as: :json
    assert_response 429
  end

  test "throttles registration after 10 attempts from same IP" do
    10.times do |i|
      post auth_register_path, params: {
        user: { name: "User #{i}", email: "user#{i}@test.com", password: "password123", password_confirmation: "password123", role: "client" }
      }, headers: { "REMOTE_ADDR" => "2.3.4.5" }, as: :json
    end

    post auth_register_path, params: {
      user: { name: "User X", email: "userx@test.com", password: "password123", password_confirmation: "password123", role: "client" }
    }, headers: { "REMOTE_ADDR" => "2.3.4.5" }, as: :json
    assert_response 429
  end

  test "throttles delivery requests after 10 attempts from same IP" do
    token = JwtService.encode(user_id: users(:john).id, role: "client")
    headers = { "Authorization" => "Bearer #{token}", "REMOTE_ADDR" => "3.4.5.6" }

    10.times do |i|
      post delivery_request_path, params: {
        delivery_request: {
          description: "Item #{i}", weight: 1,
          pick_up_address: { street: "A", city: "Nairobi", country: "Kenya" },
          delivery_address: { street: "B", city: "Nairobi", country: "Kenya" }
        }
      }, headers: headers.merge("Idempotency-Key" => SecureRandom.hex), as: :json
    end

    post delivery_request_path, params: {
      delivery_request: {
        description: "Item X", weight: 1,
        pick_up_address: { street: "A", city: "Nairobi", country: "Kenya" },
        delivery_address: { street: "B", city: "Nairobi", country: "Kenya" }
      }
    }, headers: headers.merge("Idempotency-Key" => SecureRandom.hex), as: :json
    assert_response 429
  end

  test "throttles driver location updates after 60 attempts from same IP" do
    driver = drivers(:james)
    token = JwtService.encode(user_id: driver.id, role: "driver")
    headers = { "Authorization" => "Bearer #{token}", "REMOTE_ADDR" => "4.5.6.7" }

    60.times do
      patch driver_location_path, params: { location: { latitude: -1.2921, longitude: 36.8219 } },
        headers: headers, as: :json
    end

    patch driver_location_path, params: { location: { latitude: -1.2921, longitude: 36.8219 } },
      headers: headers, as: :json
    assert_response 429
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
