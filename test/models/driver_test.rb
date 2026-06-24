require "test_helper"

class DriverTest < ActiveSupport::TestCase
  def valid_driver
    Driver.new(name: "James Mwangi", email: "newdriver@test.com", phone: "0712345601", password: "password123", password_confirmation: "password123")
  end

  test "is valid with all required fields" do
    assert valid_driver.valid?
  end

  test "is invalid without a name" do
    driver = valid_driver.tap { |d| d.name = nil }
    assert_not driver.valid?
    assert_includes driver.errors[:name], "can't be blank"
  end

  test "is invalid without an email" do
    driver = valid_driver.tap { |d| d.email = nil }
    assert_not driver.valid?
  end

  test "is invalid with a duplicate email" do
    existing = drivers(:james)
    duplicate = Driver.new(name: "Dup", email: existing.email, password: "password123", password_confirmation: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "normalizes email to lowercase" do
    driver = valid_driver.tap { |d| d.email = "JAMES@DRIVER.COM" }
    driver.valid?
    assert_equal "james@driver.com", driver.email
  end

  test "is invalid with a short password" do
    driver = valid_driver.tap { |d| d.password = d.password_confirmation = "abc" }
    assert_not driver.valid?
  end
end
