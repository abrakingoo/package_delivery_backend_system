require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user
    User.new(name: "John Doe", email: "newuser@test.com", password: "password123", password_confirmation: "password123")
  end

  test "is valid with all required fields" do
    assert valid_user.valid?
  end

  test "is invalid without a name" do
    user = valid_user.tap { |u| u.name = nil }
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "is invalid without an email" do
    user = valid_user.tap { |u| u.email = nil }
    assert_not user.valid?
  end

  test "is invalid with a duplicate email" do
    existing = users(:john)
    duplicate = User.new(name: "Dup", email: existing.email, password: "password123", password_confirmation: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "normalizes email to lowercase" do
    user = valid_user.tap { |u| u.email = "JOHN@EXAMPLE.COM" }
    user.valid?
    assert_equal "john@example.com", user.email
  end

  test "is invalid with a short password" do
    user = valid_user.tap { |u| u.password = u.password_confirmation = "abc" }
    assert_not user.valid?
  end
end
