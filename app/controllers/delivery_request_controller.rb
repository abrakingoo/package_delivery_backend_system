class DeliveryRequestController < ApplicationController
    before_action :validate_request_params, only: [:create]

    def create
        results = DeliveryRequestService.call(request_params)
        unless results[:success]
            render json: { Response_body: results }
        else
            render json: { Response_body: results.error }
        end
    end

    private

    def request_params
        params.require(:delivery_request).permit(:pick_up_address, :delivery_address, :description, :weight)
    end

    def validate_request_params
        required = %i[pick_up_address delivery_address description weight]
        missing = required.select { |f| request_params[f].blank? }
        render json: { error: "Missing required fields: #{missing.join(', ')}" }, status: :unprocessable_entity if missing.any?
        return
    end
end
