class ApplicationController < ActionController::API
    def authenticate_user!
        header = request.headers["Authorization"]
        token = header&.split(" ")&.last

        decoded = JWTService.decode(token)
        @current_user = User.find(decoded["user_id"])
    rescue
        render json: { error: "Unauthorized" }, status: :unauthorized
    end
    
    rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end
end
