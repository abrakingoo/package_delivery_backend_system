class RegistrationService
  def self.call(params)
    user = User.find_by(email: params[:email])

    return { success: false, message: "User already exists" } if user

    user = User.create!(params)

    {
      success: true,
      user: user,
      message: "User created"
    }
  end
end