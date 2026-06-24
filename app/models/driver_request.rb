class DriverRequest < ApplicationRecord
  belongs_to :delivery_request
  belongs_to :driver

  STATUSES = %w[pending accepted rejected].freeze
  validates :status, inclusion: { in: STATUSES }
end
