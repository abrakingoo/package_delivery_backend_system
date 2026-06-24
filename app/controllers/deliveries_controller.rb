class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delivery, only: [ :show, :update_status, :events ]

  def index
    return render json: { error: "Forbidden" }, status: :forbidden unless @current_user.is_a?(User)

    deliveries = DeliveryRequest.where(user_id: @current_user.id)
    render json: deliveries
  end

  def show
    return render json: { error: "Forbidden" }, status: :forbidden unless @delivery.user_id == @current_user.id

    render json: {
      id: @delivery.id,
      status: @delivery.status,
      description: @delivery.description,
      weight: @delivery.weight,
      driver: @delivery.driver&.slice(:id, :name, :phone),
      next_status: @delivery.next_status
    }
  end

  def events
    return render json: { error: "Forbidden" }, status: :forbidden unless @delivery.user_id == @current_user.id || @delivery.driver_id == @current_user.id

    render json: @delivery.delivery_events.order(created_at: :asc).select(:id, :event_type, :created_at)
  end

  def update_status
    return render json: { error: "Forbidden" }, status: :forbidden unless @current_user.is_a?(Driver)

    result = DeliveryStatusUpdateService.call(@delivery, params[:status], @current_user)

    if result[:success]
      render json: result[:delivery_request]
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  private

  def set_delivery
    @delivery = DeliveryRequest.find(params[:id])
  end
end
