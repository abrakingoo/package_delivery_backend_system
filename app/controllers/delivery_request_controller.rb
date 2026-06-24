class DeliveryRequestController < ApplicationController
    before_action :authenticate_user!
    before_action :validate_request_params, only: [ :create ]

    def create
        results = DeliveryRequestService.call(request_params, @current_user.id)
        if results[:success]
            render json: { response: results[:request] }, status: :created
        else
            render json: { error: results[:error], current_request_status: results[:current_request_status] }, status: :unprocessable_entity
        end
    end

    private

    def request_params
        params.require(:delivery_request).permit(:description, :weight, pick_up_address: [ :street, :city, :country ],
    delivery_address: [ :street, :city, :country ])
    end

    def validate_request_params
        required = %i[pick_up_address delivery_address description weight]
        missing = required.select { |f| request_params[f].blank? }
        render json: { error: "Missing required fields: #{missing.join(', ')}" }, status: :unprocessable_entity if missing.any?
        nil
    end
end
