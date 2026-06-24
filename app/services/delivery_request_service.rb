class DeliveryRequestService
  def self.call(params, user_id, idempotency_key)
    existing = DeliveryRequest.find_by(idempotency_key: idempotency_key)
    return { success: true, request: existing } if existing

    request = DeliveryRequest.create!(
      user_id: user_id,
      idempotency_key: idempotency_key,
      status: "pending",
      description: params[:description],
      weight: params[:weight]
    )

    GeocodeAndAssignDriverJob.perform_later(
      request.id,
      params[:pick_up_address].to_h.stringify_keys,
      params[:delivery_address].to_h.stringify_keys
    )

    { success: true, request: request }
  end
end
