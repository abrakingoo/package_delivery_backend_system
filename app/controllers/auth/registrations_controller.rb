class Auth::RegistrationsController < ApplicationController
    def create
        if params[:password] != params[:password_confirmation]
            render json: { error: "Password and password confirmation don't match" }
        end

        role = params.dig(:user, :role) || "client"
        result = RegistrationService.call(user_params, role)

        if result[:success]
            render json: {
            message: result[:message],
            user: result[:user]
            }, status: :created
        else
            render json: {
            error: result[:message]
            }, status: :conflict
        end
    end

    private
    def user_params
        params.require(:user).permit(:name, :email, :phone, :available, :role, :password, :password_confirmation)
    end
end
