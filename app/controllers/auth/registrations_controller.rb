class Auth::RegistrationsController < ApplicationController
    def create
        if params[:password] != params[:password_confirmation]
            render json: { error: "Password and password confirmation don't match" }
        end

        result = RegistrationService.call(user_params)

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
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
