class DriverRequestResponseService
  def self.call(driver_request, action)
    return { success: false, error: "Already responded" } unless driver_request.status == "pending"

    case action
    when "accept"
      delivery_request = driver_request.delivery_request

      driver_request.update!(status: "accepted")
      delivery_request.update!(status: "assigned", driver_id: driver_request.driver_id)
      driver_request.driver.update_column(:available, false)

      # delete all other pending driver requests for this delivery
      delivery_request.driver_requests
                      .where(status: "pending")
                      .where.not(id: driver_request.id)
                      .delete_all

      { success: true, delivery_request: delivery_request }

    when "reject"
      driver_request.update!(status: "rejected")

      # check if all drivers have rejected
      delivery_request = driver_request.delivery_request
      all_rejected = delivery_request.driver_requests.where(status: "pending").none?

      delivery_request.update!(status: "no_driver_found") if all_rejected

      { success: true, message: "Request rejected" }

    else
      { success: false, error: "Invalid action. Use accept or reject" }
    end
  end
end
