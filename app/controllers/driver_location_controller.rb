class DriverLocationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_driver!

  def update
    result = DriverLocationService.call(@current_user, location_params)

    if result[:success]
      render json: { location: result[:location] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def location_params
    params.require(:location).permit(:latitude, :longitude)
  end

  def require_driver!
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user.is_a?(Driver)
  end
end
