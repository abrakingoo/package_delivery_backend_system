class DeliveryRequest < ApplicationRecord
  STATUSES = %w[pending assigned accepted picked_up in_transit delivered no_driver_found].freeze

  TRANSITIONS = {
    "pending"    => "assigned",
    "assigned"   => "accepted",
    "accepted"   => "picked_up",
    "picked_up"  => "in_transit",
    "in_transit" => "delivered"
  }.freeze

  validates :status, inclusion: { in: STATUSES }

  belongs_to :user
  belongs_to :driver, optional: true
  has_many :driver_requests
  has_many :delivery_events

  def next_status
    TRANSITIONS[status]
  end

  def can_transition_to?(new_status)
    TRANSITIONS[status] == new_status
  end
end
