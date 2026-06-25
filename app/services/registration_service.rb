class RegistrationService
  def self.call(params, role)
    case role.to_s.downcase
    when "driver"
      return { success: false, message: "Driver already exists" } if Driver.exists?(email: params[:email])
      actor = Driver.create!(params.slice(:name, :email, :phone, :password, :password_confirmation))
    else
      return { success: false, message: "User already exists" } if User.exists?(email: params[:email])
      actor = User.create!(params.slice(:name, :email, :password, :password_confirmation))
    end

    { success: true, user: actor, message: "#{role.capitalize} created successfully" }
  end
end
