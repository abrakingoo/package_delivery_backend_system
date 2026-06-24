class DeliveryRequest < ApplicationRecord
  STATUSES = %w[requested assigned picked_up in_transit delivered no_driver_found].freeze

  validates :status, inclusion: { in: STATUSES }

  belongs_to :user
  belongs_to :driver, optional: true
  has_many :driver_requests
end
