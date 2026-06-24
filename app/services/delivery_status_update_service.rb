class DeliveryStatusUpdateService
  def self.call(delivery_request, new_status, driver)
    return { success: false, error: "Not your delivery" } unless delivery_request.driver_id == driver.id
    return { success: false, error: "Invalid transition from '#{delivery_request.status}' to '#{new_status}'" } unless delivery_request.can_transition_to?(new_status)

    delivery_request.update!(status: new_status)
    DeliveryEvent.create!(delivery_request: delivery_request, event_type: new_status)

    driver.update_column(:available, true) if new_status == "delivered"

    { success: true, delivery_request: delivery_request }
  end
end
