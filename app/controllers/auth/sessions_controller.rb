class Auth::SessionsController < ApplicationController
    def create
        result = AuthenticationService.call(user_params)

        if result[:success]
            render json: { token: result[:token], user: result[:user] }, status: :ok
        else
            render json: { error: result[:error] }, status: :unauthorized
        end
    end

    private
    def user_params
        params.require(:user).permit(:email, :password)
    end
end
