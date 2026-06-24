class AuthenticationService
  def self.call(params)
    return { success: false, error: "Email and password are required" } if params[:email].nil? || params[:password].nil?

    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s
    user = User.find_by(email: email)

    if user&.authenticate(password)
      token = JWTService.encode(user_id: user.id)

      { success: true, token: token, user: {
        id: user.id,
        name: user.name,
        email: user.email
      } }
    else
      { success: false, error: "Invalid email or password" }
    end
  end
end