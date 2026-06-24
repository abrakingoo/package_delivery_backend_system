class AuthenticationService
  def self.call(params)
    return { success: false, error: "Email and password are required" } if params[:email].nil? || params[:password].nil?

    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s

    actor = User.find_by(email: email) || Driver.find_by(email: email)

    if actor&.authenticate(password)
      role = actor.is_a?(Driver) ? "driver" : "client"
      token = JwtService.encode(user_id: actor.id, role: role)

      { success: true, token: token, user: { id: actor.id, name: actor.name, email: actor.email, role: role } }
    else
      { success: false, error: "Invalid email or password" }
    end
  end
end
