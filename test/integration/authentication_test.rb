require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  # Registration
  test "user registers successfully" do
    post auth_register_path, params: {
      user: { name: "New User", email: "new@example.com", password: "password123", password_confirmation: "password123", role: "client" }
    }, as: :json

    assert_response :created
    assert_equal "Client created successfully", json_response["message"]
  end

  test "driver registers successfully" do
    post auth_register_path, params: {
      user: { name: "New Driver", email: "newdriver@example.com", phone: "0700000000", available: true, password: "password123", password_confirmation: "password123", role: "driver" }
    }, as: :json

    assert_response :created
    assert_equal "Driver created successfully", json_response["message"]
  end

  test "registration fails with duplicate email" do
    post auth_register_path, params: {
      user: { name: "John Doe", email: "john@example.com", password: "password123", password_confirmation: "password123", role: "client" }
    }, as: :json

    assert_response :conflict
  end

  # Login
  test "user logs in with valid credentials" do
    post auth_login_path, params: { user: { email: "john@example.com", password: "password123" } }, as: :json

    assert_response :ok
    assert json_response["token"].present?
    assert_equal "client", json_response["user"]["role"]
  end

  test "driver logs in with valid credentials" do
    post auth_login_path, params: { user: { email: "james@driver.com", password: "password123" } }, as: :json

    assert_response :ok
    assert json_response["token"].present?
    assert_equal "driver", json_response["user"]["role"]
  end

  test "login fails with invalid credentials" do
    post auth_login_path, params: { user: { email: "john@example.com", password: "wrongpassword" } }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
