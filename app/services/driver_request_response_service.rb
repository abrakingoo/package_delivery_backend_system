class DriverRequestResponseService
  def self.call(driver_request, action)
    case action
    when "accept"
      result = nil

      ActiveRecord::Base.transaction do
        driver_request.lock!

        return { success: false, error: "Already responded" } unless driver_request.status == "pending"

        delivery_request = driver_request.delivery_request
        driver_request.update!(status: "accepted")
        delivery_request.update!(status: "assigned", driver_id: driver_request.driver_id)
        driver_request.driver.update_column(:available, false)

        delivery_request.driver_requests
                        .where(status: "pending")
                        .where.not(id: driver_request.id)
                        .delete_all

        result = { success: true, delivery_request: delivery_request }
      end

      result

    when "reject"
      return { success: false, error: "Already responded" } unless driver_request.status == "pending"

      driver_request.update!(status: "rejected")

      delivery_request = driver_request.delivery_request
      all_rejected = delivery_request.driver_requests.where(status: "pending").none?
      delivery_request.update!(status: "no_driver_found") if all_rejected

      { success: true, message: "Request rejected" }

    else
      { success: false, error: "Invalid action. Use accept or reject" }
    end
  end
end
