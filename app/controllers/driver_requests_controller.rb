class DriverRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_driver!

  def respond
    driver_request = DriverRequest.find_by(delivery_request: params[:id], driver: @current_user)
    return render json: { error: "Not found" }, status: :not_found unless driver_request

    result = DriverRequestResponseService.call(driver_request, params[:response_action])

    if result[:success]
      render json: result, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def require_driver!
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user.is_a?(Driver)
  end
end
