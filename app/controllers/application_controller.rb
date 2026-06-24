class ApplicationController < ActionController::API
    def authenticate_user!
        header = request.headers["Authorization"]
        token = header&.split(" ")&.last

        decoded = JwtService.decode(token)
        return render json: { error: "Unauthorized" }, status: :unauthorized unless decoded

        @current_user = if decoded["role"] == "driver"
          Driver.find_by(id: decoded["user_id"])
        else
          User.find_by(id: decoded["user_id"])
        end

        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
    rescue
        render json: { error: "Unauthorized" }, status: :unauthorized
    end

    rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Not found" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    rescue_from ActionController::ParameterMissing do |e|
        render json: {
        error: e.message
        }, status: :bad_request
    end
end
